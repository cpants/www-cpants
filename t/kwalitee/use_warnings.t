use WWW::CPANTS;
use WWW::CPANTS::Test;

test_kwalitee('use_warnings',
  ['TOBYINK/Platform-Windows-0.002.tar.gz', 0], # 2206
  ['TOBYINK/Platform-Unix-0.002.tar.gz', 0], # 2264
  ['BOOK/Acme-MetaSyntactic-errno-1.003.tar.gz', 0], # 2889
  ['ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['TXH/Template-Plugin-Filter-MinifyHTML-0.02.tar.gz', 0], # 3484
  ['LTP/Game-Life-0.05.tar.gz', 0], # 6535
  ['PJB/Speech-Speakup-1.04.tar.gz', 0], # 7410
  ['JBAZIK/Archive-Ar-1.15.tar.gz', 0], # 7983
  ['SULLR/Net-SSLGlue-1.03.tar.gz', 0], # 8720
  ['SHARYANTO/Term-ProgressBar-Color-0.00.tar.gz', 0], # 9746

  # no .pm files
  ['RCLAMP/cvn-0.02.tar.gz', 1],

  # .pod without package declaration
  ['ETHER/Moose-2.1209.tar.gz', 1],
);

done_testing;
