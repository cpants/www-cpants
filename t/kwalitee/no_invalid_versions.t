use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  # string in version
  ['TIMA/Bundle-Melody-Test-0.9.6a.tar.gz', 0], # 2042
  ['JHARDING/Text-Typoifier-0.04a.tar.gz', 0], # 2334
  ['SPECTRUM/Math-BigSimple-1.1a.tar.gz', 0], # 3269
  ['TSKIRVIN/HTML-FormRemove-0.3a.tar.gz', 0], # 3625
  ['TBONE/Chess-Elo-1.0a.tar.gz', 0], # 3979

  # exponential
  ['ALTREUS/Catalyst-Authentication-Store-MongoDB-1e-4.tar.gz', 0], # 3788 (1e-4)

  # version from other module
  ['ROBAU/Data-ACL-0.02.tar.gz', 0], # 2844

  # scalar ref
  ['MAUKE/Defaults-Mauke-0.09.tar.gz', 1], # 3136

  # my empty string
  ['INGY/YAML-MLDBM-0.10.tar.gz', 0], # 3420

  # others
  ['ARTO/CGI-Application-Plugin-Config-IniFiles-0.03.tar.gz', 0], # 3004
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('no_invalid_versions');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " no_invalid_versions: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details;
    note explain $details;
  }
}

done_testing;
