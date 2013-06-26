use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['J/JJ/JJUDD/DBIx-Class-TimeStamp-HiRes-v1.0.0.tar.gz', 0], # 2596
  ['N/NI/NIELSD/Speech-Google-0.5.tar.gz', 0], # 2907
  ['S/SC/SCILLEY/POE/Component/IRC/Plugin/IRCDHelp-0.02.tar.gz', 0], # 3243
  ['A/AN/ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['J/JE/JEEN/WebService-Aladdin-0.08.tar.gz', 0], # 4287
  ['S/SM/SMUELLER/Math-SymbolicX-Complex-1.01.tar.gz', 0], # 4719
  ['I/IA/IAMCAL/Flickr-API-1.06.tar.gz', 0], # 5172
  ['A/AN/ANANSI/Anansi-ObjectManager-0.06.tar.gz', 0], # 5246
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('has_human_readable_license');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " has_humanreadable_license: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
