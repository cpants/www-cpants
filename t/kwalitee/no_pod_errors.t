use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['A/AL/ALEXP/Catalyst-Model-Proxy-0.04.tar.gz', 0], # 3671
  ['L/LE/LEEYM/Geo-Coder-Cache-0.06.tar.gz', 0], # 3907
  ['S/SU/SULLR/Net-PcapWriter-0.71.tar.gz', 0], # 5337
  ['L/LT/LTP/Game-Life-0.05.tar.gz', 0], # 6535
  ['J/JH/JHALLOCK/StormX-Query-DeleteWhere-0.10.tar.gz', 0], # 6869
  ['D/DS/DSYRTM/File-BetweenTree-1.02.tar.gz', 0], # 7590
  ['J/JH/JHALLOCK/GappX-Dialogs-0.005.tar.gz', 0], # 7766
  ['F/FI/FIBO/Task-Viral-20130508.tar.gz', 0], # 8128
  ['J/JS/JSOBRIER/WebService-Browshot-1.11.0.tar.gz', 0], # 9434
  ['S/SA/SALVA/Class-StateMachine-0.23.tar.gz', 0], # 9859
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('no_pod_errors');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " no_pod_errors: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
