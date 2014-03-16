use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['CHENGANG/Log-Lite-0.05.tar.gz', 0], # 2739
  ['SCILLEY/POE/Component/IRC/Plugin/IRCDHelp-0.02.tar.gz', 0], # 3243
  ['ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['HITHIM/Socket-Mmsg-0.02.tar.gz', 0], # 3946
  ['FAYLAND/Acme-CPANAuthors-Chinese-0.26.tar.gz', 0], # 4474
  ['BENNIE/ACME-KeyboardMarathon-1.15.tar.gz', 0], # 4479
  ['ALEXP/Catalyst-Model-DBI-0.32.tar.gz', 0], # 4686
  ['YTURTLE/Nephia-Plugin-Response-YAML-0.01.tar.gz', 0], # 4948
  ['CHENRYN/Nagios-Plugin-ByGmond-0.01.tar.gz', 0], # 5159
  ['IAMCAL/Flickr-API-1.06.tar.gz', 0], # 5172
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('metayml_has_license');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " metayml_has_license: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
