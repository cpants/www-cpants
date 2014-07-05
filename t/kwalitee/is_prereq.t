use strict;
use warnings;
use WWW::CPANTS::Test;

plan skip_all => 'todo';

test_kwalitee('is_prereq',
  ['BOOK/Acme-MetaSyntactic-errno-1.003.tar.gz', 0], # 2889
  ['COOLMEN/Test-More-Color-0.04.tar.gz', 0], # 2963
  ['ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['HITHIM/Socket-Mmsg-0.02.tar.gz', 0], # 3946
  ['COOLMEN/Test-Mojo-More-0.04.tar.gz', 0], # 4301
  ['SMUELLER/Math-SymbolicX-Complex-1.01.tar.gz', 0], # 4719
  ['CHENRYN/Nagios-Plugin-ByGmond-0.01.tar.gz', 0], # 5159
  ['SMUELLER/Math-Symbolic-Custom-CCompiler-1.03.tar.gz', 0], # 5244
  ['OVNTATAR/GitHub-Jobs-0.04.tar.gz', 0], # 5322
  ['MUGENKEN/Uninets-Check-Modules-MongoDB-0.02.tar.gz', 0], # 5412
);

done_testing;
