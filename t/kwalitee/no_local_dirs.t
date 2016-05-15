use WWW::CPANTS;
use WWW::CPANTS::Test;

test_kwalitee('no_local_dirs',
  # local, but no .pm files
  ['ERMEYERS/Bundle-Modules-2006.0606.tar.gz', 1], # 29296

  # perl5 (with non-portable files)
  # ['PERLER/MooseX-Attribute-Deflator-2.1.3.tar.gz', 0], # 109876

  # fatlib
  ['GETTY/Installer-0.005.tar.gz', 0], # 295629
);

done_testing;
