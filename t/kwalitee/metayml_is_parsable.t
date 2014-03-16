use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  # No META.yml
  ['UNBIT/Net-uwsgi-1.1.tar.gz', 0], # 2409
  ['ANANSI/Anansi-Singleton-0.02.tar.gz', 0], # 2664
  ['NIELSD/Speech-Google-0.5.tar.gz', 0], # 2907
  ['ANANSI/Anansi-Class-0.03.tar.gz', 0], # 3028
  ['ANANSI/Anansi-Actor-0.04.tar.gz', 0], # 3157
  ['ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['MANIGREW/SEG7-1.0.1.tar.gz', 0], # 3847
  ['HITHIM/Socket-Mmsg-0.02.tar.gz', 0], # 3946
  ['STEFANOS/Net-SMTP_auth-SSL-0.2.tar.gz', 0], # 4058

  # Stream does not end with newline character
  ['SCILLEY/POE/Component/IRC/Plugin/IRCDHelp-0.02.tar.gz', 0], # 3243
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('metayml_is_parsable');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " metayml_is_parsable: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
