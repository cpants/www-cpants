use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['UNBIT/Net-uwsgi-1.1.tar.gz', 0], # 2409
  ['NIELSD/Speech-Google-0.5.tar.gz', 0], # 2907
  ['ANANSI/Anansi-Actor-0.04.tar.gz', 0], # 3157
  ['SCILLEY/POE/Component/IRC/Plugin/IRCDHelp-0.02.tar.gz', 0], # 3243
  ['ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['HITHIM/Socket-Mmsg-0.02.tar.gz', 0], # 3946
  ['CINDY/AnyEvent-HTTPD-CookiePatch-v0.1.0.tar.gz', 0], # 4162
  ['BENNIE/ACME-KeyboardMarathon-1.15.tar.gz', 0], # 4479
  ['MLX/Algorithm-Damm-1.001.002.tar.gz', 0], # 4537

  # 'meta-spec' => '1.1' is kind of broken, but it's not regarded
  # as a fatal error as of CPAN::Meta 2.132830.
  ['JOSEPHW/XML-Writer-0.545.tar.gz', 1],
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('metayml_conforms_to_known_spec');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " metayml_conforms_to_known_spec: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
