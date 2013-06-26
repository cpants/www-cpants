use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['J/JE/JEROMEMCK/Net-ICQ-On-1.7.tar.gz', 0], # 1005
  ['A/AR/ARCANEZ/WWW-Mailchimp-0.006_02.tar.gz', 0], # 1007
  ['M/ME/MEWILCOX/apache.authznetldap.02.tar.gz', 0], # 1051
  ['I/ID/IDIVISION/nginx.pm.tar.gz', 0], # 1059
  ['M/MA/MALUKU/sofu-config/sofu-config-0.2.tar.gz', 0], # 1059
  ['Z/ZL/ZLIPTON/Bundle-Bonsai-0.02.tar.gz', 0], # 1075
  ['A/AN/ANDK/Memo-bindist-any-bin-2-archname-compiler.tar.gz', 0], # 1076
  ['I/ID/IDIVISION/nginx-0.0.1.tar.gz', 0], # 1082
  ['M/MT/MTHURN/Devel-Fail-Make-1.005.tar.gz', 0], # 1088
  ['I/IL/ILYAZ/os2/tk/binary/update-03.zip', 0], # 1125
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('package_version_matches_dist_version');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " package_version_matches_dist_version: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
