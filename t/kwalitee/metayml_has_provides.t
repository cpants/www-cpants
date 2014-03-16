use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['TOBYINK/Platform-Windows-0.002.tar.gz', 0], # 2206
  ['TOBYINK/Platform-Unix-0.002.tar.gz', 0], # 2264
  ['COOLMEN/Test-More-Color-0.04.tar.gz', 0], # 2963
  ['ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['HITHIM/Socket-Mmsg-0.02.tar.gz', 0], # 3946
  ['COOLMEN/Test-Mojo-More-0.04.tar.gz', 0], # 4301
  ['SMUELLER/Math-SymbolicX-Complex-1.01.tar.gz', 0], # 4719
  ['CHENRYN/Nagios-Plugin-ByGmond-0.01.tar.gz', 0], # 5159
  ['SMUELLER/Math-Symbolic-Custom-CCompiler-1.03.tar.gz', 0], # 5244
  ['LTP/Game-Life-0.05.tar.gz', 0], # 6535
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('metayml_has_provides');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " metayml_has_provides: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
