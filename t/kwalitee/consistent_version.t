use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['G/GA/GAAS/Perl-API-0.01.tar.gz', 0], # 2003
  ['T/TI/TIMA/Bundle-Melody-Test-0.9.6a.tar.gz', 0], # 2042
  ['P/PI/PINYAN/bitflags-0.10.tar.gz', 0], # 2053
  ['Q/QJ/QJZHOU/killperl-1.01.tar.gz', 0], # 2069
  ['A/AW/AWRIGLEY/prep-1.03.tar.gz', 0], # 2125
  ['N/NI/NI-S/Regexp-0.001.tar.gz', 0], # 2137
  ['L/LE/LEOCHARRE/m4a2mp3-1.01.tar.gz', 0], # 2161
  ['N/NK/NKUITSE/pathup-1.01.tar.gz', 0], # 2190
  ['A/AN/ANDK/CPAN-Test-Dummy-Perl5-Make-1.05.tar.gz', 0], # 2225
  ['C/CW/CWEST/ACME-Error-0.03.tar.gz', 0], # 2233
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
