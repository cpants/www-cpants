use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['GUGOD/WWW-Shorten-0rz-0.07.tar.gz', 0], # 14671
  ['CLKAO/IPC-Run-SafeHandles-0.04.tar.gz', 0], # 19431
  ['TBR/WKHTMLTOPDF-0.02.tar.gz', 0], # 19819
  ['MONS/Test-More-UTF8-0.04.tar.gz', 0], # 19952
  ['SKAUFMAN/Template-Plugin-Devel-StackTrace-0.02.tar.gz', 0], # 19960
  ['LUKEC/Test-Mock-LWP-0.06.tar.gz', 0], # 20054
  ['GAOU/Ubigraph-0.05.tar.gz', 0], # 20092
  ['YVESAGO/Jifty-Plugin-Userpic-0.9.tar.gz', 0], # 20161
  ['YVESAGO/Jifty-Plugin-SiteNews-0.9.tar.gz', 0], # 20249
  ['BOLAV/DateTime-Format-Duration-DurationString-0.03.tar.gz', 0], # 20527
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('no_broken_auto_install');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " has_better_auto_install: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
