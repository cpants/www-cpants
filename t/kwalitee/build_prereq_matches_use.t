use WWW::CPANTS;
use WWW::CPANTS::Test;

plan skip_all => 'todo';

test_kwalitee('build_prereq_matches_use',
  ['JEEN/Lingua-KO-TypoCorrector-0.04.tar.gz', 0], # 3308
  ['YUTA/Cv-Pango-0.28.tar.gz', 0], # 5356
  ['MARCEL/Web-Library-0.01.tar.gz', 0], # 7345
  ['MARCEL/Web-Library-UnderscoreJS-0.01.tar.gz', 0], # 8041
  ['ETHER/Package-Variant-1.001004.tar.gz', 0], # 8195
  ['SULLR/Net-SSLGlue-1.03.tar.gz', 0], # 8720
  ['TOKUHIROM/Exporter-Auto-0.03.tar.gz', 0], # 9881
  ['AINAME/Test-More-Hooks-0.11.tar.gz', 0], # 10344
  ['IANKENT/MongoDB-Simple-0.004.tar.gz', 0], # 10827
  ['SAILTHRU/Sailthru-Client-2.001.tar.gz', 0], # 11388
);

done_testing;
