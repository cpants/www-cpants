use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['U/UN/UNBIT/Net-uwsgi-1.1.tar.gz', 0], # 2409
  ['N/NI/NIELSD/Speech-Google-0.5.tar.gz', 0], # 2907
  ['C/CO/COOLMEN/Test-More-Color-0.04.tar.gz', 0], # 2963
  ['A/AP/APIOLI/YAMC-0.2.tar.gz', 0], # 3245
  ['B/BE/BENMEYER/Finance-btce-0.02.tar.gz', 0], # 3575
  ['S/SJ/SJQUINNEY/MooseX-Types-EmailAddress-1.1.2.tar.gz', 0], # 4257
  ['R/RS/RSHADOW/libmojolicious-plugin-human-perl_0.6.orig.tar.gz', 0], # 4504
  ['L/LE/LEPREVOST/Math-SparseMatrix-Operations-0.06.tar.gz', 0], # 4593
  ['S/SR/SRPATT/Finance-Bank-CooperativeUKPersonal-0.02.tar.gz', 0], # 4991
  ['S/SU/SULLR/Net-PcapWriter-0.71.tar.gz', 0], # 5337
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('manifest_matches_dist');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " manifest_matches_dist: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
