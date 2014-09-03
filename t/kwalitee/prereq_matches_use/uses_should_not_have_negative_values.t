use strict;
use warnings;
use WWW::CPANTS::Test;

test_context_stash([
  'EXODIST/Test-Simple-1.001003.tar.gz',
], sub {
  my $stash = shift;
  my %uses = %{ $stash->{uses} || {} };
  for my $key (keys %uses) {
    for my $package (keys %{ $uses{$key} }) {
      ok $uses{$key}{$package} > 0, "$package is used $uses{$key}{$package} times";
    }
  }
});

done_testing;
