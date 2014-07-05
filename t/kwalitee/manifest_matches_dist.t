use strict;
use warnings;
use WWW::CPANTS::Test;

test_kwalitee('manifest_matches_dist',
  ['UNBIT/Net-uwsgi-1.1.tar.gz', 0], # 2409
  ['NIELSD/Speech-Google-0.5.tar.gz', 0], # 2907
  ['COOLMEN/Test-More-Color-0.04.tar.gz', 0], # 2963
  ['APIOLI/YAMC-0.2.tar.gz', 0], # 3245
  ['BENMEYER/Finance-btce-0.02.tar.gz', 0], # 3575
  ['SJQUINNEY/MooseX-Types-EmailAddress-1.1.2.tar.gz', 0], # 4257
  ['RSHADOW/libmojolicious-plugin-human-perl_0.6.orig.tar.gz', 0], # 4504
  ['LEPREVOST/Math-SparseMatrix-Operations-0.06.tar.gz', 0], # 4593
  ['SRPATT/Finance-Bank-CooperativeUKPersonal-0.02.tar.gz', 0], # 4991
  ['SULLR/Net-PcapWriter-0.71.tar.gz', 0], # 5337
);

done_testing;
