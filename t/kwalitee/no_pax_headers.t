use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['L/LA/LAWALSH/mem-0.3.0.tar.gz', 0], # 1596
  ['Z/ZA/ZAR/Mojolicious-Plugin-Captcha-0.01.tar.gz', 0], # 3591
  ['A/AT/ATRICKETT/Config-Trivial-0.50.tar.gz', 0], # 10028
  ['L/LA/LAWALSH/mem-0.3.1.tar.gz', 0], # 11201
  ['L/LA/LAWALSH/P-1.0.19.tar.gz', 0], # 17520
  ['L/LA/LAWALSH/P-1.0.20.tar.gz', 0], # 17760
  ['M/MA/MARKOV/XML-Compile-SOAP12-2.03.tar.gz', 0], # 19182
  ['M/MA/MARKOV/Net-OAuth2-0.53.tar.gz', 0], # 20529
  ['M/MA/MARKOV/XML-LibXML-Simple-0.93.tar.gz', 0], # 22821
  ['T/TB/TBENK/App-nrun-v1.0.0_1.tar.gz', 0], # 27074
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('no_pax_headers');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " no_pax_headers: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
