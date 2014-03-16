use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['UNBIT/Net-uwsgi-1.1.tar.gz', 0], # 2409
  ['NIELSD/Speech-Google-0.5.tar.gz', 0], # 2907
  ['COOLMEN/Test-More-Color-0.04.tar.gz', 0], # 2963
  ['APIOLI/YAMC-0.2.tar.gz', 0], # 3245
  ['BENMEYER/Finance-btce-0.02.tar.gz', 0], # 3575
  ['SJQUINNEY/MooseX-Types-EmailAddress-1.1.2.tar.gz', 0], # 4257
  ['RSHADOW/libmojolicious-plugin-human-perl_0.6.orig.tar.gz', 0], # 4504
  ['LEPREVOST/Math-SparseMatrix-Operations-0.06.tar.gz', 0], # 4593
  ['SRPATT/Finance-Bank-CooperativeUKPersonal-0.02.tar.gz', 0], # 4991
  ['SULLR/Net-PcapWriter-0.71.tar.gz', 0], # 5337
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
