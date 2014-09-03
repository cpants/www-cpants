use strict;
use warnings;
use WWW::CPANTS::Test;

test_context_stash([
  'ETHER/Acme-LookOfDisapproval-0.006.tar.gz',
], sub {
  my $stash = shift;
  is $stash->{abstracts_in_pod}{"Acme::LookOfDisapproval"} => "send warnings with \x{ca0}_\x{ca0}";
});

done_testing;
