use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['U/UN/UNBIT/Net-uwsgi-1.1.tar.gz', 0], # 2409
  ['A/AN/ANANSI/Anansi-Singleton-0.02.tar.gz', 0], # 2664
  ['N/NI/NIELSD/Speech-Google-0.5.tar.gz', 0], # 2907
  ['D/DA/DAVIEIRA/Data_Translate-0.3.tar.gz', 0], # 2970
  ['A/AN/ANANSI/Anansi-Class-0.03.tar.gz', 0], # 3028
  ['A/AN/ANANSI/Anansi-Actor-0.04.tar.gz', 0], # 3157
  ['A/AN/ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['M/MA/MANIGREW/SEG7-1.0.1.tar.gz', 0], # 3847
  ['H/HI/HITHIM/Socket-Mmsg-0.02.tar.gz', 0], # 3946
  ['S/ST/STEFANOS/Net-SMTP_auth-SSL-0.2.tar.gz', 0], # 4058
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('has_meta_yml');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " has_meta_yml: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
