use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['IDIVISION/nginx.pm.tar.gz', 0], # 1059
  ['ANDK/Memo-bindist-any-bin-2-archname-compiler.tar.gz', 0], # 1076
  ['DAMOG/WWW-Tumblr-0.tar.gz', 0], # 1235
  ['PIROLIX/MIME_Base32_Readable.zip', 0], # 1461
  ['STEFANOS/Text-Phonetic-MatchRatingCodex-1-0.tar.gz', 0], # 1466
  ['WILSONPM/OutlineNumber.tar.gz', 0], # 1798
  ['STEFANOS/Text-Phonetic-Caverphone.tar.gz', 0], # 1912
  ['JACKS/SelfStubber.tar.gz', 0], # 1934
  ['DAHILLMA/Geo-GoogleEarth-Document-modules.tar.gz', 0], # 1965
  ['SMAN/rpn.tar.gz', 0], # 1966
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('has_version');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " has_version: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
