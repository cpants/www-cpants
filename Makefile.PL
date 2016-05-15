use 5.020;
use ExtUtils::MakeMaker::CPANfile;

WriteMakefile(
  NAME          => 'WWW::CPANTS',
  AUTHOR        => 'Kenichi Ishigaki <ishigaki@cpan.org>',
  VERSION_FROM  => 'lib/WWW/CPANTS.pm',
  ABSTRACT_FROM => 'lib/WWW/CPANTS.pm',
  LICENSE       => 'perl',
  MIN_PERL_VERSION => '5.020000',
  META_MERGE => {
    resources => {
      repository => 'https://github.com/cpants/www-cpants',
    },
  },
);
