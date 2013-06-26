use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['U/UN/UNBIT/Net-uwsgi-1.1.tar.gz', 0], # 2409
  ['N/NI/NIELSD/Speech-Google-0.5.tar.gz', 0], # 2907
  ['A/AN/ANANSI/Anansi-Actor-0.04.tar.gz', 0], # 3157
  ['S/SC/SCILLEY/POE/Component/IRC/Plugin/IRCDHelp-0.02.tar.gz', 0], # 3243
  ['A/AN/ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['H/HI/HITHIM/Socket-Mmsg-0.02.tar.gz', 0], # 3946
  ['C/CI/CINDY/AnyEvent-HTTPD-CookiePatch-v0.1.0.tar.gz', 0], # 4162
  ['B/BE/BENNIE/ACME-KeyboardMarathon-1.15.tar.gz', 0], # 4479
  ['M/ML/MLX/Algorithm-Damm-1.001.002.tar.gz', 0], # 4537
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('metayml_conforms_spec_current');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " metayml_conforms_spec_current: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
