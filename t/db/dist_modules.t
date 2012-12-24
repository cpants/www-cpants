use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;

{
  my $db = db('DistModules', explain => 1);

  for (0..1) { # repetition doesn't break things?
    $db->set_test_data(
      cols => [qw/dist distv module released/],
      rows => [
        [qw/DistA DistA-0.01 ModuleA 100/],
        [qw/DistA DistA-0.01 ModuleB 100/],
        [qw/DistA DistA-0.01 ModuleC 100/],
        [qw/DistB DistB-0.01 ModuleE 150/],
        [qw/DistA DistA-0.02 ModuleA 200/],
        [qw/DistA DistA-0.02 ModuleB 200/],
        [qw/DistA DistA-0.02 ModuleC 200/],
        [qw/DistA DistA-0.02 ModuleD 200/],
        [qw/DistB DistB-0.02 ModuleA 250/],
        [qw/DistB DistB-0.02 ModuleE 250/],
        [qw/DistA DistA-0.03 ModuleB 300/],
        [qw/DistA DistA-0.03 ModuleC 300/],
        [qw/DistA DistA-0.03 ModuleD 300/],
      ],
    );

    no_scan_table {
      my $dists = $db->fetch_dists_by_modules([qw/ModuleA/]);
      eq_or_diff $dists => [qw/DistB/], "ModuleA belongs to DistB now";
    };

    no_scan_table {
      my $dists = $db->fetch_dists_by_modules([qw/ModuleB/]);
      eq_or_diff $dists => [qw/DistA/], "ModuleB belongs to DistA";
    };

    no_scan_table {
      my $dists = $db->fetch_dists_by_modules([qw/ModuleB ModuleC/]);
      eq_or_diff $dists => [qw/DistA/], "Both ModuleB and ModuleC belong to DistA";
    };

    no_scan_table {
      my $dists = $db->fetch_dists_by_modules([qw/ModuleA ModuleC/]);
      eq_or_diff $dists => [qw/DistA DistB/], "ModuleA belongs to DistB and ModuleC belong to DistA";
    };

    no_scan_table {
      my $dists = $db->fetch_dists_by_modules([qw/ModuleA ModuleE/]);
      eq_or_diff $dists => [qw/DistB/], "Both ModuleA and ModuleD belong to DistB";
    };

    no_scan_table {
      my $modules = $db->fetch_dist_modules('DistA-0.03');
      eq_or_diff $modules => [
        {
          dist => 'DistA',
          distv => 'DistA-0.03',
          file => undef,
          module => 'ModuleB',
          released => 300,
          version => undef,
        },
        {
          dist => 'DistA',
          distv => 'DistA-0.03',
          file => undef,
          module => 'ModuleC',
          released => 300,
          version => undef,
        },
        {
          dist => 'DistA',
          distv => 'DistA-0.03',
          file => undef,
          module => 'ModuleD',
          released => 300,
          version => undef,
        },
      ], "dist_modules";
    };
  }

  $db->remove;
}

done_testing;
