use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['M/MS/MSTROUT/pumpkin-pragma-placeholder-0.001.tar.gz', 0], # 961
  ['S/SE/SEVEAS/Term-Multiplexed-0.1.0.tar.gz', 0], # 1701
  ['P/PB/PBLAIR/Copy-From-Git-0.000302.tar.gz', 0], # 2235
  ['U/UN/UNBIT/Net-uwsgi-1.1.tar.gz', 0], # 2409
  ['N/NI/NIELSD/Speech-Google-0.5.tar.gz', 0], # 2907
  ['N/NK/NKH/Devel-Depend-Cl-0.06.tar.gz', 0], # 3540
  ['S/SE/SEMUELF/WWW-Github-Files-0.02.tar.gz', 0], # 3634
  ['M/MU/MUIR/modules/rinetd.pl-1.2.tar.gz', 0], # 4319
  ['S/SR/SRPATT/Finance-Bank-CooperativeUKPersonal-0.02.tar.gz', 0], # 4991
  ['N/NA/NANARDON/RT-Interface-Email-Filter-CheckMessageId-0.1.tar.gz', 0], # 5398
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('has_tests');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " has_tests: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
