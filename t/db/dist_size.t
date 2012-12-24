use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;

{
  my $db = db('DistSize', explain => 1);

  my $kwalitee_db = db('Kwalitee')->set_test_data(
    cols => [qw/analysis_id distv author is_latest/],
    rows => [
      [qw/1 Dist1 Author 1/],
      [qw/2 Dist2 Author 1/],
      [qw/3 Dist3 Author 1/],
      [qw/4 Dist4 Author 1/],
      [qw/5 Dist5 Author 1/],
    ],
  );

  for (0..1) { # repetition doesn't break things?
    $db->set_test_data(
      cols => [qw/analysis_id size_packed size_unpacked/],
      rows => [
        [1, 5000, 50000],
        [2, 500000000, 700000000],
        [3, 500, 700],
        [4, 50000, 70000],
        [5, 30000, 120000],
      ],
    );

    no_scan_table {
      my $stats = $db->fetch_packed_size_stats;
      eq_or_diff $stats => [
        { cat => '> 5000 KB', count => 1, sort => 500000000 },
        { cat => '> 40 KB', count => 1, sort => 50000 },
        { cat => '> 20 KB', count => 1, sort => 30000 },
        { cat => '> 3 KB', count => 1, sort => 5000 },
        { cat => 'less than 1 KB', count => 1, sort => 500 },
      ], "correct packed stats";
    };

    no_scan_table {
      my $stats = $db->fetch_unpacked_size_stats;
      eq_or_diff $stats => [
        { cat => '> 5000 KB', count => 1, sort => 700000000 },
        { cat => '> 100 KB', count => 1, sort => 120000 },
        { cat => '> 50 KB', count => 1, sort => 70000 },
        { cat => '> 40 KB', count => 1, sort => 50000 },
        { cat => 'less than 1 KB', count => 1, sort => 700 },
      ], "correct unpacked stats";
    };

    no_scan_table {
      my $dists = $db->fetch_largest_dists;
      eq_or_diff $dists => [
        {author => 'Author', distv => 'Dist2',
         packed => 500000000, unpacked => 700000000},
        {author => 'Author', distv => 'Dist5',
         packed => 30000, unpacked => 120000},
        {author => 'Author', distv => 'Dist4',
         packed => 50000, unpacked => 70000},
        {author => 'Author', distv => 'Dist1',
         packed => 5000, unpacked => 50000},
        {author => 'Author', distv => 'Dist3',
         packed => 500, unpacked => 700},
      ], "correct largest dists";
    };
  }

  $db->remove;
  $kwalitee_db->remove;
}

done_testing;
