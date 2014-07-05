package WWW::CPANTS::Analyze::Context;

use strict;
use warnings;
use Archive::Any::Lite;
use CPAN::DistnameInfo;
use WWW::CPANTS::AppRoot;
use WWW::CPANTS::Log;
use WWW::CPANTS::Util::JSON;
use File::Spec;
use File::Basename;
use Path::Extended;
use IO::Capture::Stdout;
use IO::Capture::Stderr;
use Digest::MD5 qw/md5_hex/;
use IO::Zlib;

sub new {
  my ($class, %args) = @_;

  unless ($args{dist}) {
    $class->log(warn => "requires dist");
    return;
  }

  $args{dist} =~ s{\\}{/}g;  # for Windows
  my $distinfo = CPAN::DistnameInfo->new($args{dist});
  unless ($distinfo->dist) {
    $class->log(warn => "$args{dist} seems not a normal CPAN module distribution");
    return;
  }

  my %stash = (
    dist => $distinfo->dist,
    package => $distinfo->filename || $args{dist},
    vname => $distinfo->distvname,
    extension => $distinfo->extension || 'unknown',
    version => $distinfo->version,
    author => $distinfo->cpanid,
  );

  my %capture;
  unless ($args{no_capture} or $INC{'Test/More.pm'}) {
    %capture = (
      out => IO::Capture::Stdout->new,
      err => IO::Capture::Stderr->new,
    );
    $capture{$_}->start for qw/out err/;
  }

  bless {
    stash => \%stash,
    args => \%args,
    distinfo => $distinfo,
    capture => \%capture,
    pid => $$,
  }, $class;
}

sub set {
  my ($self, %hash) = @_;
  for (keys %hash) {
    $self->{stash}{$_} = $hash{$_};
  }
}

sub set_error {
  my ($self, %hash) = @_;
  for (keys %hash) {
    $self->{stash}{error}{$_} = $hash{$_};
  }
}

sub set_kwalitee {
  my ($self, %hash) = @_;
  for (keys %hash) {
    $self->{stash}{kwalitee}{$_} = $hash{$_};
  }
}

sub stash { shift->{stash} }

sub dump_stash {
  my ($self, $pretty) = @_;
  if ($pretty) {
    encode_pretty_json($self->{stash});
  }
  else {
    encode_json($self->{stash});
  }
}

sub tmpdir {
  my $self = shift;
  unless ($self->{tmpdir}) {
    my $hash = md5_hex($self->tarball);
    $self->{tmpdir} = dir('tmp/analyze/', $$, $hash)->mkpath;
  }
  $self->{tmpdir};
}

sub tmpfile {
  my $self = shift;
  my $file = file($self->tmpdir, File::Basename::basename($self->tarball));
  my $dist = file($self->dist);
  $self->set(released_epoch => $dist->mtime);

  unless ($dist->copy_to($file)) {
    $self->log(error => "Can't create tmpfile: $!");
    $self->set_error(cpants => "Can't create tmpfile: $!");
    $self->set(extractable => 0);
    return;
  }
  $self->set(size_packed => -s $file);
  $file;
}

sub distvname { shift->{distinfo}->distvname }

sub extract {
  my $self = shift;

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
    $archive = Archive::Any::Lite->new($tmpfile) or die "Can't extract $tmpfile";
    $archive->extract($tmpdir, {tar_filter_cb => sub {
      my $entry = shift;
      if ($entry->name eq Archive::Tar::Constant::PAX_HEADER() or $entry->type eq 'x' or $entry->type eq 'g') {
        push @pax_headers, $entry->name;
        return;
      }
      return 1;
    }});
  };
  if (@pax_headers) {
    $self->set(no_pax_headers => 0);
    $self->set_error(no_pax_headers => join ',', @pax_headers);
  } else {
    $self->set(no_pax_headers => 1);
  }

  if (my $error = $@) {
    $self->set(extractable => 0);
    $self->set_error(extractable => $error);
    $self->set_kwalitee(extractable => 0);
    unlink $tmpfile;
    return;
  }
  elsif (@link_errors or @warnings) {
    # broken but some of the files may probably be extracted
    $self->set(extractable => 0);
    my %errors;
    $errors{link_errors} = \@link_errors if @link_errors;
    $errors{warnings} = \@warnings if @warnings;
    $self->set_error(extractable => \%errors) if %errors;
    $self->set_kwalitee(extractable => 0);
  }
  else {
    $self->set(extractable => 1);
  }

  unlink $tmpfile;

  if (opendir my $dh, $tmpdir) {
    my @entities = grep /\w/, readdir $dh;
    if (@entities == 1) {
      $self->distdir($tmpdir, $entities[0]);
      if (-d $self->distdir) {
        my $distvname = $self->distvname;
        $distvname =~ s/\-withoutworldwritables//;
        $distvname =~ s/\-TRIAL//;
        $self->set(extracts_nicely => ($distvname eq $entities[0] ? 1 : 0));
      }
      else {
        $self->distdir($tmpdir);
        $self->set(extracts_nicely => 0);
      }
    }
    else {
      $self->distdir($tmpdir);
      $self->set(extracts_nicely => 0);
    }
  }
  else {
    $self->set(extractable => 0);
    $self->log(error => "Can't open $tmpdir: $!");
    $self->set_error(cpants => "Can't open $tmpdir: $!");
    $self->set_kwalitee(extractable => 0);
    return;
  }
  return 1;
}

sub stop_capturing {
  my $self = shift;
  for (qw/out err/) {
    next unless $self->{capture}{$_};
    if ($self->{capture}{$_}{'IO::Capture::status'} eq 'Busy') {
      $self->{capture}{$_}->stop;
    }
  }
}

# for Module::CPANTS::Analyse/Kwalitee compatibility

*d        = \&stash;
*testdir  = \&tmpdir;
*testfile = \&tmpfile;

sub dist { shift->{args}{dist} }
sub tarball { shift->{distinfo}->filename }
sub distdir {
  my $self = shift;
  if (@_) {
    $self->{distdir} = File::Spec->catdir(@_);
    $self->{distdir} =~ s|\\|/|g if $^O eq 'MSWin32';
  }
  $self->{distdir};
}
sub mck { shift->{kwalitee} }
sub opts { shift->{args} }
sub capture_stdout { shift->{capture}{out} }
sub capture_stderr { shift->{capture}{err} }

sub x_opts {
  my $self = shift;
  unless ($self->{_x_opts}) {
    my %opts;
    if (my $x_cpants = $self->stash->{meta_yml}{x_cpants}) {
      if (my $ignore = $x_cpants->{ignore}) {
        if (ref $ignore eq ref {}) {
          $opts{ignore} = $ignore;
        }
        else {
          $self->set_error(x_cpants => "x_cpants ignore should be a hash reference (key: metric, value: reason to ignore)");
        }
      }
    }
    $self->{_x_opts} = \%opts;
  }
  $self->{_x_opts};
}

sub DESTROY {
  my $self = shift;
  $self->stop_capturing;
  if ($self->{pid} == $$ and $self->{tmpdir}) {
    unless ($self->{stash}{error}{cpants} && $self->{debug}) {
      $self->{tmpdir}->remove;
    }
  }
}

1;

__END__

=head1 NAME

WWW::CPANTS::Analyze::Context

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 dump_stash
=head2 extract
=head2 set
=head2 set_error
=head2 set_kwalitee
=head2 stash
=head2 stop_capturing

=head2 d
=head2 dist
=head2 distdir
=head2 distvname
=head2 capture_stdout
=head2 capture_stderr
=head2 mck
=head2 opts
=head2 x_opts
=head2 tarball
=head2 testdir
=head2 testfile
=head2 tmpdir
=head2 tmpfile

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
