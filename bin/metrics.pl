use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

WWW::CPANTS::Script::metrics->run_directly;

package WWW::CPANTS::Script::metrics;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::Kwalitee;

sub _run {
  my $self = shift;
  save_metrics();
}

