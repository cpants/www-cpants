use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['UNBIT/Net-uwsgi-1.1.tar.gz', 0], # 2409
  ['NIELSD/Speech-Google-0.5.tar.gz', 0], # 2907
  ['MUIR/modules/rinetd.pl-1.2.tar.gz', 0], # 4319
  ['SRPATT/Finance-Bank-CooperativeUKPersonal-0.02.tar.gz', 0], # 4991
  ['IAMCAL/Flickr-API-1.06.tar.gz', 0], # 5172
  ['PJB/Speech-Speakup-1.04.tar.gz', 0], # 7410
  ['FIBO/Task-Viral-20130508.tar.gz', 0], # 8128
  ['ADAMBA/Algorithm-MOS-0.001.tar.gz', 0], # 8570
  ['FIBO/Task-BeLike-FIBO-20130508.tar.gz', 0], # 8922
  ['FIBO/Dist-Zilla-MintingProfile-Author-FIBO-20130507.tar.gz', 0], # 8932
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('easily_repackageable_by_debian');
  my $result = $metric->{code}->($context->stash, $metric);
  is $result => $test->[1], $tarball->basename . " easily_repackageable_by_debian: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
