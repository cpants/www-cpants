use strict;
use warnings;
use WWW::CPANTS::Test;

test_context_stash([
  'INA/Char/Latin10/Char-Latin10-0.87.tar.gz',
], sub {
  my $stash = shift;
  ok $stash->{extracts_nicely}, "extracts nicely";
});

done_testing;
