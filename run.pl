use strict;
use warnings;
use lib "lib";

WWW::CPANTS::Script::process_cpan->run_directly;

package WWW::CPANTS::Script::process_cpan;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::Process::Queue;
use WWW::CPANTS::Process::Analysis;
use Time::Piece;

sub _options {qw/workers=n cpan=s force/}

sub _run {
  my ($self, @args) = @_;

  $self->{cpan} ||= '/home/ishigaki/cpan_mirror';

  die $self->usage unless $self->{cpan};

  $self->{verbose} = 1;
  $self->{logger} = 1;

  WWW::CPANTS::Process::Queue->new->enqueue_cpan(%$self);
  WWW::CPANTS::Process::Analysis->new->process_queue(%$self);
}
