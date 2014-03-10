package WWW::CPANTS::Script::Base;

use strict;
use warnings;
use base 'CLI::Dispatch::Command';
use WWW::CPANTS::AppRoot;
use WWW::CPANTS::Config;
use WWW::CPANTS::Log;
use Time::Piece;
use Time::Seconds;

our $FORCE_DEBUG = 0;
our $VERBOSE = $^O eq 'MSWin32' ? 1 : 0;

sub options {
  my $self = shift;
  my @options = qw/trace profile/;
  if ($self->can('_options')) {
    push @options, $self->_options;
  }
  @options;
}

sub run {
  my $self = shift;

  my ($class) = lc(ref $self || $self) =~ /::([^:]+)$/;
  my $pidfile = $self->{_pidfile} = file("tmp/pids/$class.pid");
  die "another process is running\n" if $pidfile->exists;
  $pidfile->save($$, {mkdir => 1});

  local $SIG{INT} = sub { warn "Terminating on SIGINT"; $self->_remove_pidfile; exit };

  $self->{cpan}    ||= WWW::CPANTS::Config->cpan;
  $self->{backpan} ||= WWW::CPANTS::Config->backpan;

  $self->logger(1);
  if ($VERBOSE or $self->{verbose}) {
    $self->logger->add(
      screen => {
        maxlevel => 'debug',
        minlevel => 'emergency',
        message_layout => '%L [%P] %m',
      },
    );
  }
  if ($FORCE_DEBUG or $self->{debug}) {
    $self->logger->add(
      file => {
        filename => dir('log')->file('debug.log')->path,
        maxlevel => 'debug',
        minlevel => 'debug',
        timeformat => '%Y-%m-%d %H:%M:%S',
        message_layout => '%T %L [%P] %m',
      },
    );
  }

  my ($name) = (ref $self) =~ /::(\w+)$/;

  $self->log(info => "$name: started");
  my $start = time;

  my $maintenance_file = appfile('__maintenance__');
  if ($maintenance_file->exists) {
    $maintenance_file = '';
  }
  else {
    $maintenance_file->save("$name: $start");
  }

  $self->_run(@_);
  my $end = time;

  $self->log(info => "$name: ended");

  $self->log(
    info => "$name:",
      localtime($start)->strftime('%Y-%m-%d %H:%M:%S'),
      "to", localtime($end)->strftime('%Y-%m-%d %H:%M:%S'),
      "(" . Time::Seconds->new($end - $start)->pretty . ")",
  );

  if ($maintenance_file) {
    $maintenance_file->remove;
  }

  $self->_remove_pidfile;
}

sub _run { die "not implemented\n" }

sub _remove_pidfile {
  my $self = shift;
  my $pidfile = $self->{_pidfile} or return;
  return unless $pidfile->exists;
  my $pid = $pidfile->slurp;
  $pidfile->remove if $pid && $pid eq $$;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Script::Base - a base class; not to run

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 options
=head2 run

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
