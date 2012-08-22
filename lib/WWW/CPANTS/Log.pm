package WWW::CPANTS::Log;

use strict;
use warnings;
use WWW::CPANTS::AppRoot;
use Log::Handler;
use Exporter::Lite;

our @EXPORT = qw/logger log/;

my $logger;
my $logdir = dir('log')->mkdir;

__PACKAGE__->logger(1);

sub logger {
  my $self = shift;
  if (@_) {
    if (!$_[0]) {
      undef $logger;
    }
    else {
      # default logger

      $logger ||= Log::Handler->new;
      $logger->add(
        file => {
          filename => $logdir->file('info.log')->path,
          maxlevel => 'info',
          minlevel => 'notice',
          timeformat => '%Y-%m-%d %H:%M:%S',
          message_layout => '%T %L %m',
        },
        file => {
          filename => $logdir->file('warning.log')->path,
          maxlevel => 'warning',
          minlevel => 'warning',
          timeformat => '%Y-%m-%d %H:%M:%S',
          message_layout => '%T %L %m (%C)',
        },
        file => {
          filename => $logdir->file('error.log')->path,
          maxlevel => 'error',
          minlevel => 'emergency',
          timeformat => '%Y-%m-%d %H:%M:%S',
          message_layout => '%T %L %m (%C)',
        },
      );
    }
  }
  $logger;
}

sub log { shift; $logger and $logger->log(@_) }

1;

__END__

=head1 NAME

WWW::CPANTS::Log

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
