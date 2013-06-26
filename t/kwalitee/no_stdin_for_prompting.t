use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['G/GM/GMCCAR/Jabber-SimpleSend-0.03.tar.gz', 0], # 3455
  ['S/SP/SPEEVES/Apache-AuthenNIS-0.13.tar.gz', 0], # 4517
  ['S/SP/SPEEVES/Apache2-AuthenSmb-0.01.tar.gz', 0], # 5219
  ['K/KR/KROW/DBIx-Password-1.9.tar.gz', 0], # 5478
  ['G/GE/GEOTIGER/Data-Fax-0.02.tar.gz', 0], # 5944
  ['G/GE/GEOTIGER/CGI-Getopt-0.13.tar.gz', 0], # 6014
  ['S/SP/SPEEVES/Apache2-AuthNetLDAP-0.01.tar.gz', 0], # 6855
  ['S/SP/SPEEVES/Apache-AuthNetLDAP-0.29.tar.gz', 0], # 6952
  ['A/AM/AMALTSEV/XAO-MySQL-1.02.tar.gz', 0], # 7242
  ['B/BH/BHODGES/Mail-IMAPFolderSearch-0.03.tar.gz', 0], # 7326
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('no_stdin_for_prompting');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " no_stdin_for_prompting: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
