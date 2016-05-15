package WWW::CPANTS::Bin::Model::Archive;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use WWW::CPANTS::Util::Kwalitee;
use File::Basename qw/basename/;
use File::Spec;
use Archive::Any::Lite;
use CPAN::DistnameInfo;

sub new ($class, $path) {
  if (!-f $path) {
    log(warn => "$path is not a file");
    return;
  }

  my $info = distinfo($path) // {};
  return if $info->{perl6}; # ignore silently

  unless ($info->{dist}) {
    log(warn => "$path seems not a normal CPAN module distribution");
    return;
  }

  my %stash = (
    dist => $info->{dist},
    package => $info->{path},
    vname => $info->{distvname},
    extension => $info->{extension} // 'unknown',
    version => $info->{version},
    author => $info->{cpanid},
  );

  bless {
    stash => \%stash,
    distinfo => $info,
    args => {dist => $path},
    pid => $$,
  }, $class;
}

sub should_be_ignored ($self) {
  my $dist = $self->{stash}{dist};
  return 1 if !defined $dist;
  return 1 if $dist =~ /^(?:perl|perl_debug|parrot|Rakudo\-Star|kurila)$/;
  return 1 if $dist =~ /^SiePerl\-5\./;
  return 1 if $dist =~ /^perl[-]?5\./;
  return 1 if $dist =~ /^Perl6-Pugs/;
  return 1 if $dist =~ /^p54rc/;
  return 0;
}

sub has_perl_stuff ($self) {
  !exists $self->{stash}{has_no_perl_stuff} ? 1 : 0;
}

sub check_perl_stuff ($self) {
  for (@{$self->stash->{files_array} // []}) {
    return 1 if /\.(?:pm|PL)$/;
    return 1 if /\bMETA\.(?:yml|json)$/;
  }
  $self->stash->{has_no_perl_stuff} = 1;
  return;
}

sub calc_kwalitee ($self) {
  $self->set(kwalitee => {});
  my %x_ignore = %{ $self->x_opts->{ignore} || {} };
  for my $indicator (@{kwalitee_indicators()}) {
    next if $indicator->{needs_db};
    my $ret;
    {
      my @warnings;
      local $SIG{__WARN__} = sub (@args) { push @warnings, @args };
      $ret = $indicator->{code}($self->stash, $indicator);
      if (@warnings) {
        $self->set_error(cpants_warnings => $indicator->{name}.": ".join '', @warnings);
      }
    }
    $ret = ($ret && $ret > 0) ? 1 : $ret // 0;  # normalize

    my $name = $indicator->{name};
    if ($x_ignore{$name} && $indicator->{ignorable}) {
      $ret = -1 if !$ret; # success or ignore
      if (my $error = $self->stash->{error}{$name}) {
        $self->set_error($name => "$error [ignored]");
      }
    }

    $self->set_kwalitee($name => $ret);
    next if $indicator->{is_experimental};
  }

  # this value is tentative and will be finalized later,
  # but anyway this should always look like an actual kwalitee score,
  # even when the process happens to fail.
  $self->set_kwalitee(kwalitee => calc_kwalitee_score($self->stash->{kwalitee}));
  $self->set_kwalitee(core_kwalitee => calc_kwalitee_score($self->stash->{kwalitee}, 'core'));
}

sub tmpdir ($self) {
  $self->{tmpdir} //= do {
    my $hash = substr(md5($self->tarball), 0, 10);
    my $dir = dir("tmp/analyze/$$/$hash");
    $dir->mkpath;
    $dir;
  };
}

sub tmpfile ($self) {
  my $file = file($self->tmpdir, basename($self->tarball));
  my $dist = Path::Tiny::path($self->dist); # external
  $self->set(released_epoch => file_mtime($dist));

  $dist->copy($file) or do {
    my $message = "Can't create a tmpfile: $!";
    log(error => $message);
    $self->set_error(cpants => $message);
    $self->set(extractable => 0);
    return;
  };
  $self->set(size_packed => -s $file);
  $file;
}

sub distvname ($self) { $self->{distinfo}{distvname} }

# for Module::CPANTS::Analyse/Kwalitee compatibility

*d = \&stash;
*testdir = \&tmpdir;
*testfile = \&tmpfile;

sub dist ($self) { $self->{args}{dist} }
sub tarball ($self) { $self->{distinfo}{filename} }
sub distdir ($self, @args) {
  if (@args) {
    my $dir = File::Spec->catdir(@args);
    $dir =~ s|\\|/|g if $^O eq 'MSWin32';
    $self->{distdir} = $dir;
  }
  $self->{distdir};
}

sub mck ($self) { $self->{kwalitee} }
sub opts ($self) { $self->{args} }

sub x_opts ($self) {
  $self->{_x_opts} //= do {
    my %opts;
    my $meta = $self->stash->{meta_yml};
    if (my $x_cpants = $meta ? $meta->{x_cpants} : undef) {
      if (my $ignore = $x_cpants->{ignore}) {
        if (ref $ignore eq 'HASH') {
          $opts{ignore} = $ignore;
        } else {
          $self->set_error(x_cpants => "x_cpants ignore should be a hash reference (key: metric, value: reason to ignore)");
        }
      }
    }
    \%opts;
  };
}

sub DESTROY ($self) {
  if ($self->{pid} eq $$ and $self->{tmpdir}) {
    eval { $self->{tmpdir}->remove_tree({safe => 0}) } unless $self->{stash}{error}{cpants} && $self->{debug};
  }
}


sub extract ($self) {
  my $tmpfile = $self->tmpfile or return;
  my $tmpdir  = $self->tmpdir;

  my $archive;
  my @warnings;
  my @link_errors;
  my @pax_headers;
  eval {
    local $Archive::Zip::ErrorHandler = sub { die @_ };
    local $SIG{__WARN__} = sub {
      if ($_[0] =~ /^Making (?:hard|symbolic) link from '([^']+)'/) {
        push @link_errors, $1;
        return;
      }
      if ($_[0] =~ /^Invalid header/) {
        push @warnings, $_[0];
        return;
      }
      die @_;
    };

    # NOTE
    # $Archive::Tar::CHMOD is turned off by CPAN::ParseDistribution,
    # which is nice and secure in general, but we need it to be true
    # here to check buildtool_not_executable.
    local $Archive::Tar::CHMOD = 1;
    $archive = Archive::Any::Lite->new($tmpfile) or croak "Can't extract $tmpfile";
    $archive->extract($tmpdir, {tar_filter_cb => sub ($entry) {
      if ($entry->name eq Archive::Tar::Constant::PAX_HEADER() or $entry->type eq 'x' or $entry->type eq 'g') {
        push @pax_headers, $entry->name;
        return;
      }
      return 1;
    }});
  };
  if (my $error = $@) {
    $self->set(extractable => 0);
    $self->set_error(extractable => $error);
    $self->set_kwalitee(extractable => 0);
    unlink $tmpfile;
    return;
  };

  if (@link_errors or @warnings) {
    # broken but some of the files may probably be extracted
    $self->set(extractable => 0);
    my %errors;
    $errors{link_errors} = \@link_errors if @link_errors;
    $errors{warnings} = \@warnings if @warnings;
    $self->set_error(extractable => \%errors) if %errors;
    $self->set_kwalitee(extractable => 0);
  } else {
    $self->set(extractable => 1);
  }

  if (@pax_headers) {
    $self->set(no_pax_headers => 0);
    $self->set_error(no_pax_headers => join ',', @pax_headers);
  } else {
    $self->set(no_pax_headers => 1);
  }

  unlink $tmpfile;

  return 1;
}

sub is_extracted_nicely ($self) {
  my $tmpdir = $self->tmpdir;

  if (opendir my $dh, $tmpdir) {
    my @entities = grep /\w/, readdir $dh;
    if (@entities == 1) {
      $self->distdir($tmpdir, $entities[0]);
      if (-d $self->distdir) {
        my $distvname = $self->distvname;
        $distvname =~ s/\-withoutworldwritables//;
        $distvname =~ s/\-TRIAL[0-9]*//;
        $self->set(extracts_nicely => ($distvname eq $entities[0] ? 1 : 0));
      } else {
        $self->distdir($tmpdir);
        $self->set(extracts_nicely => 0);
      }
    } else {
      $self->distdir($tmpdir);
      $self->set(extracts_nicely => 0);
    }
  } else {
    my $message = "Can't open $tmpdir: $!";
    $self->log(error => $message);
    $self->set_error(cpants => $message);
    $self->set(extractable => 0);
    $self->set_kwalitee(extractable => 0);
    return;
  }
  return 1;
}

sub set ($self, %hash) {
  $self->{stash}{$_} = $hash{$_} for keys %hash;
}

sub set_error ($self, %hash) {
  $self->{stash}{error}{$_} = $hash{$_} for keys %hash;
}

sub set_kwalitee ($self, %hash) {
  $self->{stash}{kwalitee}{$_} = $hash{$_} for keys %hash;
}

sub stash ($self) { $self->{stash} }

sub dump_stash ($self, $pretty = 0) {
  if ($pretty) {
    hide_internal(encode_pretty_json($self->{stash}));
  } else {
    hide_internal(encode_json($self->{stash}));
  }
}

1;
