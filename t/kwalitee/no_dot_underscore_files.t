use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['L/LE/LEPT/String-Iota-0.85.tar.gz', 0], # 2441
  ['D/DA/DAMOG/Data-Format-HTML-0.5.1.tar.gz', 0], # 2737
  ['B/BR/BRENTDAX/Template-Plugin-Lingua-Conjunction-0.02.tar.gz', 0], # 2875
  ['S/SO/SOCK/WWW-Search-UrbanDictionary-0.4.tar.gz', 0], # 3176
  ['C/CL/CLADI/SmarTalk_v10.tar.gz', 0], # 3289
  ['K/KA/KAOSAGNT/CGI-Session-Serialize-php-1.1.tar.gz', 0], # 3336
  ['E/EB/EBRAGIN/Cache-Memcached-Tags-0.02.tar.gz', 0], # 3399
  ['A/AH/AHICOX/XML-Parser-YahooRESTGeocode-0.2.tar.gz', 0], # 3503
  ['R/RE/RECSKY/Bot-BasicBot-Pluggable-Module-Pastebin-0.01.tar.gz', 0], # 3663
  ['S/SO/SOCK/WWW-Yahoo-KeywordExtractor-0.5.2.tar.gz', 0], # 3806
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('no_dot_underscore_files');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " no_dot_underscore_files: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
