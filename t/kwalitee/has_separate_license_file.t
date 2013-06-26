use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['T/TO/TOBYINK/Platform-Windows-0.002.tar.gz', 0], # 2206
  ['T/TO/TOBYINK/Platform-Unix-0.002.tar.gz', 0], # 2264
  ['B/BO/BOOK/Acme-MetaSyntactic-errno-1.003.tar.gz', 0], # 2889
  ['C/CO/COOLMEN/Test-More-Color-0.04.tar.gz', 0], # 2963
  ['A/AN/ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['H/HI/HITHIM/Socket-Mmsg-0.02.tar.gz', 0], # 3946
  ['C/CO/COOLMEN/Test-Mojo-More-0.04.tar.gz', 0], # 4301
  ['M/MU/MUGENKEN/Bundle-Unicheck-0.02.tar.gz', 0], # 4596
  ['S/SM/SMUELLER/Math-SymbolicX-Complex-1.01.tar.gz', 0], # 4719
  ['C/CH/CHENRYN/Nagios-Plugin-ByGmond-0.01.tar.gz', 0], # 5159
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('has_separate_license_file');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " has_separate_license_file: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
