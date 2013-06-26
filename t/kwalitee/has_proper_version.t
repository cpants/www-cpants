use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['W/WI/WINTRU/Mica-1.a.0.tar.gz', 0], # 1196
  ['T/TS/TSUNODA/Sledge-Plugin-SNMP-0.01a.tar.gz', 0], # 1767
  ['T/TI/TIMA/Bundle-Melody-Test-0.9.6a.tar.gz', 0], # 2042
  ['C/CF/CFABER/libuuid-perl_0.02.orig.tar.gz', 0], # 2091
  ['D/DA/DANPEDER/MIME-Base32-1.02a.tar.gz', 0], # 3136
  ['M/MO/MOBILEART/Net-OmaDrm-0.10a.tar.gz', 0], # 3208
  ['A/AS/ASKADNA/CGI-Application-Plugin-Eparam-0.04f.tar.gz', 0], # 3228
  ['S/SP/SPECTRUM/Math-BigSimple-1.1a.tar.gz', 0], # 3269
  ['T/TS/TSKIRVIN/HTML-FormRemove-0.3a.tar.gz', 0], # 3625
  ['S/SH/SHY/Wifi/Wifi-0.01a.tar.gz', 0], # 3767
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('has_proper_version');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " has_proper_version: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
