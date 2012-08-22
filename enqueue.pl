#!perl
use strict;
use warnings;
use lib "lib";

WWW::CPANTS::Script::EnqueueCPAN->run_directly;

package WWW::CPANTS::Script::EnqueueCPAN;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::Process::Queue;

sub _options {qw/cpan=s force/}

sub _run {
  my ($self, @args) = @_;

  my $process = WWW::CPANTS::Process::Queue->new(%$self);
  $process->enqueue_dists(@args);
}

__END__

=head1 NAME

enqueue.pl - enqueue distributions

=head1 USAGE

  enqueue.pl --workers 5 --cpan /path/to/cpan --force [dists]

