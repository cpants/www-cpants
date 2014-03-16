use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['JEROMEMCK/Net-ICQ-On-1.7.tar.gz', 0], # 1005
  ['ARCANEZ/WWW-Mailchimp-0.006_02.tar.gz', 0], # 1007
  ['MEWILCOX/apache.authznetldap.02.tar.gz', 0], # 1051
  ['IDIVISION/nginx.pm.tar.gz', 0], # 1059
  ['MALUKU/sofu-config/sofu-config-0.2.tar.gz', 0], # 1059
  ['ZLIPTON/Bundle-Bonsai-0.02.tar.gz', 0], # 1075
  ['ANDK/Memo-bindist-any-bin-2-archname-compiler.tar.gz', 0], # 1076
  ['IDIVISION/nginx-0.0.1.tar.gz', 0], # 1082
  ['MTHURN/Devel-Fail-Make-1.005.tar.gz', 0], # 1088
  ['ILYAZ/os2/tk/binary/update-03.zip', 0], # 1125

  # illegal provides
  ['DJERIUS/Lua-API-0.02.tar.gz', 0],
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
