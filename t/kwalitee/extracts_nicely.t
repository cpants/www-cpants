use strict;
use warnings;
use WWW::CPANTS::Test;

test_kwalitee('extracts_nicely',
  ['STEFANOS/MIME-Base2-1.1.tar.gz', 0], # 1229
  ['STEFANOS/MIME-Base16-1.2.tar.gz', 0], # 1366
  ['STEFANOS/URI-scp-0.03.tar.gz', 0], # 1399
  ['STEFANOS/URI-ftpes-0.02.tar.gz', 0], # 1404
  ['STEFANOS/URI-ftps-0.03.tar.gz', 0], # 1406
  ['STEFANOS/Data-Password-Entropy-Old-0.2.tar.gz', 0], # 1536
  ['STEFANOS/MIME-Base91-1.1.tar.gz', 0], # 1835
  ['STEFANOS/MIME-Base85-1.1.tar.gz', 0], # 1908
  ['STEFANOS/Finance-Currency-Convert-ECB-0.3.tar.gz', 0], # 1910
  ['XINZHENG/BIE-Data-HDF5-Data-0.01.tar.gz', 0], # 2002
);

done_testing;
