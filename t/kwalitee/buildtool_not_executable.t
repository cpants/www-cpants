use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

plan skip_all => "This test doesn't work well under Windows" if $^O eq 'MSWin32';

my @tests = (
  ['C/CO/COOLMEN/Test-More-Color-0.04.tar.gz', 0], # 2963
  ['C/CO/CODECHILD/Thread-SharedTreeSet-0.01.tar.gz', 0], # 3191
  ['C/CO/CODECHILD/Set-Definition-0.01.tar.gz', 0], # 4242
  ['J/JE/JEEN/WebService-Aladdin-0.08.tar.gz', 0], # 4287
  ['D/DS/DSYRTM/Guitar-Scale-0.06.tar.gz', 0], # 4469
  ['O/OV/OVNTATAR/GitHub-Jobs-0.04.tar.gz', 0], # 5322
  ['E/EG/EGILES/X11-Terminal-v1.0.0.tar.gz', 0], # 6205
  ['L/LT/LTP/Game-Life-0.05.tar.gz', 0], # 6535
  ['L/LT/LTP/IBM-SONAS-0.021.tar.gz', 0], # 7177
  ['D/DS/DSYRTM/File-BetweenTree-1.02.tar.gz', 0], # 7590
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('buildtool_not_executable');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " buildtool_not_executable: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
