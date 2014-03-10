use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['T/TO/TOBYINK/Platform-Windows-0.002.tar.gz', 0], # 2206
  ['T/TO/TOBYINK/Platform-Unix-0.002.tar.gz', 0], # 2264
  ['S/SC/SCILLEY/POE/Component/IRC/Plugin/IRCDHelp-0.02.tar.gz', 0], # 3243
  ['A/AN/ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['T/TX/TXH/Template-Plugin-Filter-MinifyHTML-0.02.tar.gz', 0], # 3484
  ['A/AN/ANANSI/Anansi-ObjectManager-0.06.tar.gz', 0], # 5246
  ['M/MA/MARCEL/Web-Library-0.01.tar.gz', 0], # 7345
  ['P/PJ/PJB/Speech-Speakup-1.04.tar.gz', 0], # 7410
  ['T/TE/TEMPIRE/Eponymous-Hash-0.01.tar.gz', 0], # 8503
  ['S/SU/SULLR/Net-SSLGlue-1.03.tar.gz', 0], # 8720

  # use 5.012 and higher
  ['Z/ZD/ZDM/Pharaoh-BootStrap-3.00.tar.gz', 1], # use 5.12.0
  ['M/MA/MALLEN/Acme-Github-Test-0.03.tar.gz', 1], # use 5.014

  # no .pm files
  ['R/RC/RCLAMP/cvn-0.02.tar.gz', 1],
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('use_strict');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " use_strict: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
