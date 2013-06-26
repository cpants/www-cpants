use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['U/UN/UNBIT/Net-uwsgi-1.1.tar.gz', 0], # 2409
  ['N/NI/NIELSD/Speech-Google-0.5.tar.gz', 0], # 2907
  ['B/BE/BENNING/Math-BaseMulti-1.00.tar.gz', 0], # 2942
  ['H/HE/HEYTRAV/Mojolicious-Plugin-Libravatar-1.08.tar.gz', 0], # 3415
  ['T/TX/TXH/Template-Plugin-Filter-MinifyHTML-0.02.tar.gz', 0], # 3484
  ['M/MA/MANIGREW/SEG7-1.0.1.tar.gz', 0], # 3847
  ['M/MU/MUIR/modules/rinetd.pl-1.2.tar.gz', 0], # 4319
  ['G/GS/GSB/WWW-Crab-Client-0.03.tar.gz', 0], # 4352
  ['R/RS/RSHADOW/libmojolicious-plugin-human-perl_0.6.orig.tar.gz', 0], # 4504
  ['S/SR/SRPATT/Finance-Bank-CooperativeUKPersonal-0.02.tar.gz', 0], # 4991
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('has_changelog');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " has_changelog: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
