use strict;
use warnings;
use ExtUtils::MakeMaker::CPANfile 0.04;

my %params = (
  NAME          => 'WWW::CPANTS',
  AUTHOR        => 'Kenichi Ishigaki <ishigaki@cpan.org>',
  VERSION_FROM  => 'lib/WWW/CPANTS.pm',
  ABSTRACT_FROM => 'lib/WWW/CPANTS.pm',
  LICENSE       => 'perl',
  test => { TESTS => 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t' },
  META_MERGE => {
    resources => {
      repository => 'https://github.com/cpants/www-cpants',
    },
    no_index => {
      directory => [qw!extlib log test_mirror tmp test_utils xt xutils!],
    },
  },
  MIN_PERL_VERSION => '5.010',
);

WriteMakefile(%params);
