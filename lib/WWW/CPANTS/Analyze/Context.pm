package WWW::CPANTS::Analyze::Context;

use strict;
use warnings;
use Archive::Any::Lite;
use CPAN::DistnameInfo;
use WWW::CPANTS::AppRoot;
use WWW::CPANTS::Log;
use File::Spec;
use Path::Extended;
use IO::Capture::Stdout;
use IO::Capture::Stderr;
use JSON::XS;
use Digest::MD5 qw/md5_hex/;

sub new {
  my ($class, %args) = @_;

  unless ($args{dist}) {
    $class->log(warn => "$args{dist} not found");
    return;
  }

  $args{dist} =~ s{\\}{/}g;  # for Windows
  my $distinfo = CPAN::DistnameInfo->new($args{dist});
  unless ($distinfo->dist) {
    $class->log(warn => "$args{dist} seems not a normal CPAN module distribution");
    return;
  }

  my %capture;
  unless ($args{no_capture} or $INC{'Test/More.pm'}) {
    %capture = (
      out => IO::Capture::Stdout->new,
      err => IO::Capture::Stderr->new,
    );
    $capture{$_}->start for qw/out err/;
  }

  bless {
    stash => { dist => $distinfo->dist },
    args => \%args,
    distinfo => $distinfo,
    capture => \%capture,
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

my $json_parser = JSON::XS->new->convert_blessed(1);
sub dump_stash {
  my ($self, $pretty) = @_;
  if ($pretty) {
    $json_parser->pretty->canonical->encode($self->{stash});
  }
  else {
    $json_parser->encode(shift->{stash});
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
  my $file = file($self->tmpdir, $self->tarball);
  unless (file($self->dist)->copy_to($file)) {
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
  eval {
    local $Archive::Zip::ErrorHandler = sub { die @_ };
    local $SIG{__WARN__} = sub { die @_ };

    $archive = Archive::Any::Lite->new($tmpfile) or die "Can't extract $tmpfile";
    $archive->extract($tmpdir);
  };
  if (my $error = $@) {
    $self->set(extractable => 0);
    $self->set_error(extract => $error);
    $self->set_kwalitee(extractable => 0);
    return;
  }
  $self->set(extractable => 1);

  unlink $tmpfile;

  if (opendir my $dh, $tmpdir) {
    my @entities = grep /\w/, readdir $dh;
    if (@entities == 1) {
      $self->distdir($tmpdir, $entities[0]);
      $self->set(extracts_nicely => ($self->distvname eq $entities[0] ? 1 : 0));
    }
    else {
      $self->distdir($tmpdir);
      $self->set(extracts_nicely => 0);
    }
  }
  else {
    $self->set(extractable => 0);
    $self->set_error(cpants => "Can't open $tmpdir: $!");
    $self->set_kwalitee(extractable => 0);
    return;
  }
  return 1;
}

# to convert version objects in the stash
# XXX: of course it's best not to use these costly conversions

{
  no warnings 'redefine';
  sub version::TO_JSON { "$_[0]" }
  sub Module::Build::Version::TO_JSON { "$_[0]" }
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
  }
  $self->{distdir};
}
sub mck { shift->{kwalitee} }
sub opts { shift->{args} }
sub capture_stdout { shift->{capture}{out} }
sub capture_stderr { shift->{capture}{err} }

sub DESTROY {
  my $self = shift;
  $self->stop_capturing;
  if ($self->{tmpdir}) {
    unless ($self->{stash}{error}{cpants}) {
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

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
