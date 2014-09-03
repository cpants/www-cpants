use strict;
use warnings;
use WWW::CPANTS::Test;

test_context_stash([
  'INGY/IO-All-0.40.tar.gz',
], sub {
  my $stash = shift;
  like $stash->{error}{has_abstract_in_pod} => qr/unknown encoding: utf8;/;
});

done_testing;
