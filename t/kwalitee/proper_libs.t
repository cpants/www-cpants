use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  # pm files not in the lib/base dir
  ['NIELSD/Speech-Google-0.5.tar.gz', 0], # 2907 (Google/TTS.pm)

  # didn't extract nicely (dot underscore files)
  ['AQUILINA/WWW-LaQuinta-Returns-0.02.tar.gz', 0], # 4055

  # multiple pm files in the basedir
  ['DGRAHAM/simpleXMLParse/simplexmlparse_v1.4.tar.gz', 0], # 4336

  # no modules
  ['LAWSONK/Gtk2-Ex-MPlayerEmbed-0.03.tar.gz', 1], # 465
  ['WOLDRICH/App-epic-0.014.tar.gz', 1], # 812
  ['TAG/AnyEvent-Peer39-0.32.tar.gz', 1], # 824
  ['CASIANO/Git-Export-0.04.tar.gz', 1], # 2593
  ['MILOVIDOV/APP-Yatranslate-0.02.tar.gz', 1], # 3773
  ['DBR/pdoc-0.900.tar.gz', 1], # 3876
  ['MUIR/modules/rinetd.pl-1.2.tar.gz', 1], # 4319
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('proper_libs');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " proper_libs: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
