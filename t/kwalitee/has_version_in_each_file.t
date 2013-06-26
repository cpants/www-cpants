use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

plan skip_all => "needs another round";

my @tests = (
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('has_version_in_each_file');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " has_version_in_each_file: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
