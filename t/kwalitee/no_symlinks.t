use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

plan skip_all => "This test doesn't work well under Windows" if $^O eq 'MSWin32';

my @tests = (
  ['C/CM/CMORRIS/Parse-Extract-Net-MAC48-0.01.tar.gz', 0], # 3094
  ['B/BR/BRUMLEVE/autobless-1.0.1.tar.gz', 0], # 3318
  ['B/BR/BRUMLEVE/wildproto-1.0.1.tar.gz', 0], # 3617
  ['B/BR/BRUMLEVE/vm-1.0.1.tar.gz', 0], # 4236
  ['C/CR/CRUSOE/Template-Plugin-Filter-ANSIColor-0.0.3.tar.gz', 0], # 4963
  ['G/GS/GSLONDON/Devel-AutoProfiler-1.200.tar.gz', 0], # 6139
  ['P/PH/PHAM/Business-Stripe-0.04.tar.gz', 0], # 6412
  ['G/GA/GAVINC/Config-Directory-0.05.tar.gz', 0], # 8774
  ['N/NE/NETVARUN/Net-Semantics3-0.10.tar.gz', 0], # 8930
  ['G/GA/GAVINC/File-DirCompare-0.7.tar.gz', 0], # 9018
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('no_symlinks');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " no_symlinks: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
