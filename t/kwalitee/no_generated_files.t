use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['SANTEX/Finance-Quant-Quotes-0.01.tar.gz', 0], # 3159
  ['SANTEX/Finance-Quant-TA-0.01.tar.gz', 0], # 3269
  ['TAKERU/Catalyst-Model-Estraier-v0.0.6.tar.gz', 0], # 6175
  ['BDFOY/Unicode-Support-0.001.tar.gz', 0], # 6633
  ['RPETTETT/Module-PortablePath-0.17.tar.gz', 0], # 6951
  ['ROBN/Class-Constant-0.06.tar.gz', 0], # 7557
  ['TUSHAR/Log-SelfHistory_0.1.tar.gz', 0], # 8412
  ['CCCP/Plugins-Factory-0.01.tar.gz', 0], # 8876
  ['JAMHED/Dancer-Plugin-Scoped-0.02fix.tar.gz', 0], # 8885
  ['JKRAMER/SQL-Beautify-0.04.tar.gz', 0], # 8972
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('no_generated_files');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " no_generated_files: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
