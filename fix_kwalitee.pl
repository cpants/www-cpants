use strict;
use warnings;
use lib "lib";

WWW::CPANTS::Script::fix_kwalitee->run_directly;

package WWW::CPANTS::Script::fix_kwalitee;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::Process::Kwalitee;

sub _run {
  my $self = shift;

  WWW::CPANTS::Process::Kwalitee->new->update_all;
}
