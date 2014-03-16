use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['ANDK/CPAN-Test-Dummy-Perl5-Make-1.05.tar.gz', 0], # 2225
  ['CWEST/ACME-Error-0.03.tar.gz', 0], # 2233

  # no modules
  ['GAAS/Perl-API-0.01.tar.gz', 1], # 2003
  ['QJZHOU/killperl-1.01.tar.gz', 1], # 2069
  ['AWRIGLEY/prep-1.03.tar.gz', 1], # 2125
  ['LEOCHARRE/m4a2mp3-1.01.tar.gz', 1], # 2161
  ['NKUITSE/pathup-1.01.tar.gz', 1], # 2190

  # no version
  ['PINYAN/bitflags-0.10.tar.gz', 1], # 2053
  ['NI-S/Regexp-0.001.tar.gz', 1], # 2137

  # undef (invalid version) only
  ['TIMA/Bundle-Melody-Test-0.9.6a.tar.gz', 1], # 2042
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('consistent_version');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " consistent_version: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
