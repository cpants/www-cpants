use strict;
use warnings;
use WWW::CPANTS::Test;

test_kwalitee('no_broken_module_install',
  ['GUGOD/Kwiki-Session-0.01.tar.gz', 0], # 7880
  ['GUGOD/Kwiki-Widgets-Links-0.01.tar.gz', 0], # 8214
  ['CLSUNG/Lingua-ZH-Segment-0.02.tar.gz', 0], # 8236
  ['RHUNDT/Catalyst-Model-Oryx-0.01.tar.gz', 0], # 8255
  ['XERN/Template-Plugin-IO-All-0.01.tar.gz', 0], # 8462
  ['IJLIAO/WWW-Scraper-ISBN-TWSrbook_Driver-0.01.tar.gz', 0], # 9139
  ['IJLIAO/WWW-Scraper-ISBN-TWYlib_Driver-0.01.tar.gz', 0], # 9199
  ['IJLIAO/WWW-Scraper-ISBN-TWTenlong_Driver-0.01.tar.gz', 0], # 9210
  ['IJLIAO/WWW-Scraper-ISBN-TWPchome_Driver-0.01.tar.gz', 0], # 9308
  ['IJLIAO/WWW-Scraper-ISBN-TWSoidea_Driver-0.01.tar.gz', 0], # 9348

  # M::I 1.04
  ['KARMAN/Dezi-UI-0.001000.tar.gz', 0],
);

done_testing;
