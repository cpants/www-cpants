use strict;
use warnings;
use WWW::CPANTS::Test;

test_kwalitee('easily_repackageable_by_fedora',
  ['CHENGANG/Log-Lite-0.05.tar.gz', 0], # 2739
  ['ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['HITHIM/Socket-Mmsg-0.02.tar.gz', 0], # 3946
  ['COOLMEN/Test-Mojo-More-0.04.tar.gz', 0], # 4301
  ['FAYLAND/Acme-CPANAuthors-Chinese-0.26.tar.gz', 0], # 4474
  ['LEV/WebService-Desk-0.1.tar.gz', 0], # 4840
  ['YTURTLE/Nephia-Plugin-Response-YAML-0.01.tar.gz', 0], # 4948
  ['CHENRYN/Nagios-Plugin-ByGmond-0.01.tar.gz', 0], # 5159
  ['IAMCAL/Flickr-API-1.06.tar.gz', 0], # 5172
  ['SMUELLER/Math-Symbolic-Custom-CCompiler-1.03.tar.gz', 0], # 5244
);

done_testing;
