use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";

WWW::CPANTS::Script::run->run_directly;

package WWW::CPANTS::Script::run;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::Process::Uploads;
use WWW::CPANTS::Process::CPAN;
use WWW::CPANTS::Process::Queue;
use WWW::CPANTS::Process::Analysis;
use WWW::CPANTS::Process::Kwalitee;
use WWW::CPANTS::Analyze::Metrics;
use WWW::CPANTS::Pages;

sub _options {qw/workers=n cpan=s backpan=s force profile trace/}

sub _notice { 'analyzing' }

sub _run {
  my ($self, @args) = @_;

  die $self->usage unless $self->{cpan};

  $self->{verbose} = 1;
  $self->{logger} = 1;

  save_metrics();
  WWW::CPANTS::Process::Uploads->new(%$self)->update;
  WWW::CPANTS::Process::CPAN->new(%$self)->update;
  WWW::CPANTS::Process::Queue->new(%$self)->enqueue_cpan;
  WWW::CPANTS::Process::Analysis->new(%$self)->process_queue;
  WWW::CPANTS::Process::Kwalitee->new(%$self)->update;
  WWW::CPANTS::Pages->update;
}
