use strict;
use warnings;
use WWW::CPANTS::Test;

test_kwalitee('no_stdin_for_prompting',
  ['GMCCAR/Jabber-SimpleSend-0.03.tar.gz', 0], # 3455
  ['SPEEVES/Apache-AuthenNIS-0.13.tar.gz', 0], # 4517
  ['SPEEVES/Apache2-AuthenSmb-0.01.tar.gz', 0], # 5219
  ['KROW/DBIx-Password-1.9.tar.gz', 0], # 5478
  ['GEOTIGER/Data-Fax-0.02.tar.gz', 0], # 5944
  ['GEOTIGER/CGI-Getopt-0.13.tar.gz', 0], # 6014
  ['SPEEVES/Apache2-AuthNetLDAP-0.01.tar.gz', 0], # 6855
  ['SPEEVES/Apache-AuthNetLDAP-0.29.tar.gz', 0], # 6952
  ['AMALTSEV/XAO-MySQL-1.02.tar.gz', 0], # 7242
  ['BHODGES/Mail-IMAPFolderSearch-0.03.tar.gz', 0], # 7326
);

done_testing;
