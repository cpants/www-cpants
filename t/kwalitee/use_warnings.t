use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
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
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('use_warnings');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " use_warnings: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
