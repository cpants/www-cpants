use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['S/SZ/SZABGAB/File-Open-OOP-0.01.tar.gz', 0], # 2431
  ['J/JH/JHTHORSEN/The-synthesizer-0.01.tar.gz', 0], # 2514
  ['T/TE/TENGU/Catalyst-Authentication-Credential-MultiFactor-1.0.tar.gz', 0], # 2577
  ['B/BD/BDFOY/Psychic-Ninja-0.10_01.tar.gz', 0], # 2689
  ['J/JH/JHTHORSEN/The-synthesizer-0.02.tar.gz', 0], # 2708
  ['Z/ZZ/ZZZ/Here-Template-0.1.tar.gz', 0], # 2793
  ['K/KI/KIMOTO/Mojolicious-Plugin-AutoRoute-0.04.tar.gz', 0], # 2811
  ['B/BD/BDFOY/Net-SSH-Perl-WithSocks-0.02.tar.gz', 0], # 2894
  ['Z/ZZ/ZZZ/Here-Template-0.2.tar.gz', 0], # 2902
  ['K/KI/KIMOTO/Mojolicious-Plugin-AutoRoute-0.02.tar.gz', 0], # 2902
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('no_mymeta_files');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " no_mymeta_files: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
