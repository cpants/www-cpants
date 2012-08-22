package WWW::CPANTS::Script::Base;

use strict;
use warnings;
use base 'CLI::Dispatch::Command';
use WWW::CPANTS::AppRoot;
use WWW::CPANTS::Log;
use Time::Piece;
use Time::Seconds;

sub options {
  my $self = shift;
  my @options = qw//;
  if ($self->can('_options')) {
    push @options, $self->_options;
  }
  @options;
}

sub run {
  my $self = shift;
  if (1 or $self->{verbose}) {
    $self->logger(1);
    $self->logger->add(
      screen => {
        maxlevel => 'debug',
        minlevel => 'emergency',
        message_layout => '%L %m',
      },
    );
  }
  if (1 or $self->{debug}) {
    $self->logger->add(
      file => {
        filename => dir('log')->file('debug.log')->path,
        maxlevel => 'debug',
        minlevel => 'debug',
        timeformat => '%Y-%m-%d %H:%M:%S',
        message_layout => '%T %L %m',
      },
    );
  }

  my $start = time;
  $self->_run(@_);
  my $end = time;

  my ($name) = (ref $self) =~ /::(\w+)$/;
  $self->log(
    info => "$name:",
      localtime($start)->strftime('%Y-%m-%d %H:%M:%S'),
      "to", localtime($end)->strftime('%Y-%m-%d %H:%M:%S'),
      "(" . Time::Seconds->new($end - $start)->pretty . ")",
  );
}

sub _run { die "not implemented\n" }

1;

__END__

=head1 NAME

WWW::CPANTS::Script::Base - a base class; not to run

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
