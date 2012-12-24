use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;

{
  my $db = db('DistDependents', explain => 1);

  for (0..1) { # repetition doesn't break things?
    $db->set_test_data(
      cols => [qw/dist dependents/],
      rows => [
        ['DistA', 'DepB,DepC,DepD'],
      ],
    );

    no_scan_table {
      my $deps = $db->fetch_dependents('DistA');
      ok $deps && @$deps, "got dependents";
      is $deps->[0] => 'DepB', "first dependents is correct";
    };

    no_scan_table {
      my $deps = $db->fetch_dependents('NotExists');
      ok $deps && !@$deps, "got no dependents";
    };
  }

  $db->remove;
}

done_testing;
