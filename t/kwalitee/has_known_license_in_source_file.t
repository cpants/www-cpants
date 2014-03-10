use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['J/JJ/JJUDD/DBIx-Class-TimeStamp-HiRes-v1.0.0.tar.gz', 0], # 2596
  ['A/AN/ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['S/SM/SMUELLER/Math-SymbolicX-Complex-1.01.tar.gz', 0], # 4719
  ['I/IA/IAMCAL/Flickr-API-1.06.tar.gz', 0], # 5172
  # =head1 AUTHOR / COPYRIGHT / LICENSE
  ['B/BJ/BJOERN/AI-CRM114-0.01.tar.gz', 1],

  # has =head1 COPYRIGHT AND LICENSE without closing =cut
  ['D/DA/DAMI/DBIx-DataModel-2.39.tar.gz', 1],

  # has =head1 LICENSE followed by =head1 COPYRIGHT
  ['Y/YS/YSASAKI/App-pfswatch-0.08.tar.gz', 1],

  # ignore inc/Devel/CheckLib
  ['D/DJ/DJERIUS/Lua-API-0.02.tar.gz', 1],
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('has_known_license_in_source_file');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " has_known_license_in_source_file: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
