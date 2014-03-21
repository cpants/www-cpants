use strict;
use warnings;
use FindBin;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze::Metrics;

save_metrics();

ok -f metrics_file(), "metrics file exists";

load_metrics();

ok is_valid_metric('extractable'), "extractable is valid";

my $kwalitee = {
  extractable => 1,
  extracts_nicely => 0,
};

{
  my $sorted = sorted_metrics($kwalitee);

  is $sorted->[0]{key} => 'extractable';
  is $sorted->[0]{value} => 1;
}

{
  my $sorted = sorted_metrics($kwalitee, requires_remedy => 1);

  is $sorted->[0]{key} => 'extractable';
  is $sorted->[0]{value} => 1;
  ok !$sorted->[0]{remedy}, "no remedy for a passing metric";

  is $sorted->[1]{key} => 'extracts_nicely';
  is $sorted->[1]{value} => 0;
  ok $sorted->[1]{remedy}, "remedy for a failing metric";
}

{
  for (@{sorted_metrics($kwalitee)}) {
    my $file = "$FindBin::Bin/kwalitee/$_->{key}.t";
    ok -e $file, "kwalitee test for $_->{key} exists";
  }
}

done_testing;
