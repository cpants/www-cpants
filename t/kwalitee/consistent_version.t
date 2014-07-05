use strict;
use warnings;
use WWW::CPANTS::Test;

test_kwalitee('consistent_version',
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

done_testing;
