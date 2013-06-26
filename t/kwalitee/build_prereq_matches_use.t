use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['J/JE/JEEN/Lingua-KO-TypoCorrector-0.04.tar.gz', 0], # 3308
  ['Y/YU/YUTA/Cv-Pango-0.28.tar.gz', 0], # 5356
  ['M/MA/MARCEL/Web-Library-0.01.tar.gz', 0], # 7345
  ['M/MA/MARCEL/Web-Library-UnderscoreJS-0.01.tar.gz', 0], # 8041
  ['E/ET/ETHER/Package-Variant-1.001004.tar.gz', 0], # 8195
  ['S/SU/SULLR/Net-SSLGlue-1.03.tar.gz', 0], # 8720
  ['T/TO/TOKUHIROM/Exporter-Auto-0.03.tar.gz', 0], # 9881
  ['A/AI/AINAME/Test-More-Hooks-0.11.tar.gz', 0], # 10344
  ['I/IA/IANKENT/MongoDB-Simple-0.004.tar.gz', 0], # 10827
  ['S/SA/SAILTHRU/Sailthru-Client-2.001.tar.gz', 0], # 11388
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('build_prereq_matches_use');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " build_prereq_matches_use: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
