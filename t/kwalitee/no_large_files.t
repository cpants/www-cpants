use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['A/AC/ACFEREN/Net-Flow-1.002.tar.gz', 0], # 27764
  ['D/DO/DOMM/Module-ExtractUse-0.30.tar.gz', 0], # 28244
  ['C/CO/COLINSC/Business-Edifact-Interchange-0.04.tar.gz', 0], # 58366
  ['K/KE/KENTNL/Gentoo-Perl-Distmap-0.2.0.tar.gz', 0], # 59822
  ['B/BI/BINGOS/Module-CoreList-2.88.tar.gz', 0], # 61044
  ['Y/YW/YWANGPERL/Test-AutomationFramework-0.058.52.tar.gz', 0], # 65676
  ['B/BA/BARBIE/Parse-CPAN-Distributions-0.08.tar.gz', 0], # 70086
  ['N/NV/NVBINDING/nvidia-ml-pl-4.304.2.tar.gz', 0], # 74049
  ['M/MA/MARCEL/Web-Library-jQueryUI-0.01.tar.gz', 0], # 77243
  ['C/CO/CODECHILD/XML-Bare-0.52.tar.gz', 0], # 84367
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('no_large_files');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " no_large_files: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
