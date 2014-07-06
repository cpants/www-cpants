use strict;
use warnings;
use WWW::CPANTS::Test;

test_kwalitee('no_pax_headers',
  ['LAWALSH/mem-0.3.0.tar.gz', 0], # 1596
  ['ZAR/Mojolicious-Plugin-Captcha-0.01.tar.gz', 0], # 3591
  ['ATRICKETT/Config-Trivial-0.50.tar.gz', 0], # 10028
  ['LAWALSH/mem-0.3.1.tar.gz', 0], # 11201
  ['LAWALSH/P-1.0.19.tar.gz', 0], # 17520
  ['LAWALSH/P-1.0.20.tar.gz', 0], # 17760
  ['MARKOV/XML-Compile-SOAP12-2.03.tar.gz', 0], # 19182
  ['MARKOV/Net-OAuth2-0.53.tar.gz', 0], # 20529
  ['MARKOV/XML-LibXML-Simple-0.93.tar.gz', 0], # 22821
  ['TBENK/App-nrun-v1.0.0_1.tar.gz', 0], # 27074
  ['MSCHILLI/libwww-perl-6.06.tar.gz', 0],
);

done_testing;
