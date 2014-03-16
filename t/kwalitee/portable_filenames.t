use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['DGL/Acme-mA-1337.1.tar.gz', 0], # 3411
  ['SCHWIGON/acme-unicode/Acme-Uenicoede-0.0501.tar.gz', 0], # 3651
  ['DGL/Acme-3mxA-1337.37.tar.gz', 0], # 4093
  ['KOORCHIK/Mojolicious-Plugin-RenderFile-0.06.tar.gz', 0], # 4114
);

# The followings are only valid for non-Win32 env
# (because invalid files will not be extracted on Win32).
push @tests, (
  ['PERFSONAR/perfSONAR_PS-Status-Common-0.09.tar.gz', 0], # 5439
  ['PERFSONAR/perfSONAR_PS-Client-Echo-0.09.tar.gz', 0], # 6654
  ['FRASE/Test-Builder-Clutch-0.05.tar.gz', 0], # 6764
  ['PERFSONAR/perfSONAR_PS-DB-File-0.09.tar.gz', 0], # 7704
  ['PERFSONAR/perfSONAR_PS-Client-LS-Remote-0.09.tar.gz', 0], # 8232
) unless $^O eq 'MSWin32';

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('portable_filenames');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " portable_filenames: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
