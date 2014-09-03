use strict;
use warnings;
use WWW::CPANTS::Test;

test_context_stash([
  'INGY/orz-0.17.tar.gz',
], sub {
  my $stash = shift;
  my $error = $stash->{error}{no_pod_errors};
  unlike $error => qr!tmp/analyse/.+/!;
});

done_testing;
