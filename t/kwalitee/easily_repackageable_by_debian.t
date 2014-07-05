use strict;
use warnings;
use WWW::CPANTS::Test;

test_kwalitee('easily_repackageable_by_debian',
  ['UNBIT/Net-uwsgi-1.1.tar.gz', 0], # 2409
  ['NIELSD/Speech-Google-0.5.tar.gz', 0], # 2907
  ['MUIR/modules/rinetd.pl-1.2.tar.gz', 0], # 4319
  ['SRPATT/Finance-Bank-CooperativeUKPersonal-0.02.tar.gz', 0], # 4991
  ['IAMCAL/Flickr-API-1.06.tar.gz', 0], # 5172
  ['PJB/Speech-Speakup-1.04.tar.gz', 0], # 7410
  ['FIBO/Task-Viral-20130508.tar.gz', 0], # 8128
  ['ADAMBA/Algorithm-MOS-0.001.tar.gz', 0], # 8570
  ['FIBO/Task-BeLike-FIBO-20130508.tar.gz', 0], # 8922
  ['FIBO/Dist-Zilla-MintingProfile-Author-FIBO-20130507.tar.gz', 0], # 8932
);

done_testing;
