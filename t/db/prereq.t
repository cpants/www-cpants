use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;

{
  my $db = db('PrereqModules', explain => 1);

  for (0..1) { # repetition doesn't break things?
    $db->set_test_data(
      cols => [qw/dist distv author prereq prereq_version type/],
      rows => [
        [qw/DistA DistA-0.01 Foo ModuleA 0.01 1/],
        [qw/DistA DistA-0.01 Foo ModuleB 0 1/],
        [qw/DistA DistA-0.01 Foo ModuleB 0 2/],
        [qw/DistA DistA-0.01 Foo Test::ModuleC 0 2/],
        [qw/DistB DistB-0.01 Bar ModuleA 0.01 1/],
        [qw/DistB DistB-0.01 Bar ModuleD 0 1/],
        [qw/DistB DistB-0.01 Bar Test::ModuleC 0 2/],
        [qw/DistB DistB-0.01 Bar Test::ModuleE 0 2/],
      ],
    );

    no_scan_table {
      my $prereqs = $db->fetch_all_prereqs;
      eq_or_diff [sort map {$_->{prereq}} @$prereqs] => [qw/ModuleA ModuleB ModuleD Test::ModuleC Test::ModuleE/], "correct prereqs";
    } "known slow query";

    no_scan_table {
      my %mapping = (
        ModuleA => 'PrereqDistA',
        ModuleB => 'PrereqDistA',
        ModuleD => 'PrereqDistD',
        'Test::ModuleC' => 'BuildPrereqDistC',
        'Test::ModuleE' => 'BuildPrereqDistE',
      );
      for (keys %mapping) {
        $db->update_prereq_dist($_ => $mapping{$_});
      }
      $db->finalize_update_prereq_dist;
      my $dists = $db->fetch_all_prereq_dists;
      eq_or_diff [sort @$dists] => [qw/BuildPrereqDistC BuildPrereqDistE PrereqDistA PrereqDistD/], "correct prereq dists";
    };

    no_scan_table {
      my $dists = $db->fetch_prereqs_of('DistA-0.01');
      eq_or_diff [sort {$a->{prereq_dist} cmp $b->{prereq_dist}} @$dists] => [
        {
          author => 'Foo',
          dist => 'DistA',
          distv => 'DistA-0.01',
          prereq => 'Test::ModuleC',
          prereq_dist => 'BuildPrereqDistC',
          prereq_version => '0',
          type => 2,
        },
        {
          author => 'Foo',
          dist => 'DistA',
          distv => 'DistA-0.01',
          prereq => 'ModuleA',
          prereq_dist => 'PrereqDistA',
          prereq_version => '0.01',
          type => 1,
        },
        {
          author => 'Foo',
          dist => 'DistA',
          distv => 'DistA-0.01',
          prereq => 'ModuleB',
          prereq_dist => 'PrereqDistA',
          prereq_version => '0',
          type => 1,
        },
        {
          author => 'Foo',
          dist => 'DistA',
          distv => 'DistA-0.01',
          prereq => 'ModuleB',
          prereq_dist => 'PrereqDistA',
          prereq_version => '0',
          type => 2,
        },
      ], "correct prereq dists of DistA-0.01";
    };

    no_scan_table {
      my $dists = $db->fetch_dependents('BuildPrereqDistC');
      eq_or_diff $dists => [qw/DistA DistB/], "correct dependents";
    };

    # PrereqDistA is required by DistA (by Foo) and DistB (by Bar).
    # So this is required by someone other than the maintainer,
    # thus is_prereq should be true. However, this may be
    # problematic if PrereqDistA is maintained by both Foo and Bar.
    no_scan_table {
      my $dist = $db->fetch_first_dependent_by_others('PrereqDistA', 'Foo');
      eq_or_diff $dist => [qw/DistB/], "correct dependent";
    };
  }

  $db->remove;
}

{ # stats
  my $db = db('PrereqModules', explain => 1)->set_test_data(
    cols => [qw/distv prereq_dist/],
    rows => [
      [qw/DistA-0.01 PrereqDistA/],
      [qw/DistA-0.01 PrereqDistB/],
      [qw/DistA-0.01 PrereqDistC/],
      [qw/DistA-0.02 PrereqDistA/],
      [qw/DistA-0.02 PrereqDistB/],
      [qw/DistA-0.02 PrereqDistC/],
      [qw/DistB-0.01 PrereqDistB/],
      [qw/DistC-0.01 PrereqDistA/],
      [qw/DistC-0.01 PrereqDistB/],
      [qw/DistC-0.01 PrereqDistC/],
      [qw/DistC-0.01 PrereqDistD/],
      [qw/DistD-0.01 PrereqDistE/],
      [qw/Task-Everything-0.01 PrereqDistA/],
      [qw/Task-Everything-0.01 PrereqDistB/],
      [qw/Task-Everything-0.01 PrereqDistC/],
      [qw/Task-Everything-0.01 PrereqDistD/],
      [qw/Task-Everything-0.01 PrereqDistE/],
    ],
  );
  my $kwalitee_db = db('Kwalitee')->set_test_data(
    serial => 'analysis_id',
    cols => [qw/dist distv is_latest/],
    rows => [
      [qw/DistA DistA-0.01 0/],
      [qw/DistA DistA-0.02 1/],
      [qw/DistB DistB-0.01 1/],
      [qw/DistC DistC-0.01 1/],
      [qw/DistD DistD-0.01 1/],
      [qw/DistE DistE-0.01 1/],
      [qw/PrereqDistA PrereqDistA-0.01 1/],
      [qw/PrereqDistB PrereqDistB-0.01 1/],
      [qw/PrereqDistC PrereqDistC-0.01 1/],
      [qw/PrereqDistD PrereqDistD-0.01 1/],
      [qw/PrereqDistE PrereqDistE-0.01 1/],
      [qw/Task-Everything Task-Everything-0.01 1/],
    ],
  );

  no_scan_table {
    my $stats = $db->fetch_stats_of_required;
    eq_or_diff $stats => [
      {cat => ">= 3", count => 3, sort => 3},
      {cat => ">= 2", count => 2, sort => 2},
      {cat => "0", count => 6, sort => undef},
    ], "stats of required";
  };

  no_scan_table {
    my $stats = $db->fetch_stats_of_requires;
    eq_or_diff $stats => [
      {cat => ">= 5", count => 1, sort => 5},
      {cat => ">= 4", count => 1, sort => 4},
      {cat => ">= 3", count => 1, sort => 3},
      {cat => ">= 1", count => 2, sort => 1},
      {cat => "0", count => 6, sort => undef},
    ], "stats of requires";
  };

  no_scan_table {
    my $dists = $db->fetch_most_required_dists;
    eq_or_diff $dists => [
      {count => 4, prereq_dist => 'PrereqDistB', rank => 1},
      {count => 3, prereq_dist => 'PrereqDistA', rank => 2},
      {count => 3, prereq_dist => 'PrereqDistC', rank => 2},
      {count => 2, prereq_dist => 'PrereqDistD', rank => 4},
      {count => 2, prereq_dist => 'PrereqDistE', rank => 4},
    ], "most required dists";
  };

  no_scan_table {
    my $dists = $db->fetch_dists_that_requires_most;
    eq_or_diff $dists => [
      {count => 4, distv => 'DistC-0.01', rank => 1},
      {count => 3, distv => 'DistA-0.02', rank => 2},
      {count => 1, distv => 'DistB-0.01', rank => 3},
      {count => 1, distv => 'DistD-0.01', rank => 3},
    ], "dists that requires most";
  };

  $db->remove;
  $kwalitee_db->remove;
}

done_testing;
