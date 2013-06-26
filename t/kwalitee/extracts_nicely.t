use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['S/ST/STEFANOS/MIME-Base2-1.1.tar.gz', 0], # 1229
  ['S/ST/STEFANOS/MIME-Base16-1.2.tar.gz', 0], # 1366
  ['S/ST/STEFANOS/URI-scp-0.03.tar.gz', 0], # 1399
  ['S/ST/STEFANOS/URI-ftpes-0.02.tar.gz', 0], # 1404
  ['S/ST/STEFANOS/URI-ftps-0.03.tar.gz', 0], # 1406
  ['S/ST/STEFANOS/Data-Password-Entropy-Old-0.2.tar.gz', 0], # 1536
  ['S/ST/STEFANOS/MIME-Base91-1.1.tar.gz', 0], # 1835
  ['S/ST/STEFANOS/MIME-Base85-1.1.tar.gz', 0], # 1908
  ['S/ST/STEFANOS/Finance-Currency-Convert-ECB-0.3.tar.gz', 0], # 1910
  ['X/XI/XINZHENG/BIE-Data-HDF5-Data-0.01.tar.gz', 0], # 2002
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('extracts_nicely');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " extracts_nicely: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
