use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;
use WWW::CPANTS::Analyze::Metrics;

{
  my $db = db('Kwalitee', explain => 1);

  for (0..1) { # repetition doesn't break things?
    $db->set_test_data(
      serial => 'analysis_id',
      cols => [qw/dist distv author is_cpan is_latest/],
      rows => [
        [qw/DistA DistA-0.01 AuthorA 0 0/],
        [qw/DistA DistA-0.02 AuthorA 0 0/],
        [qw/DistA DistA-0.03 AuthorB 1 1/],
        [qw/DistB DistB-0.01 AuthorB 1 0/],
        [qw/DistB DistB-0.02 AuthorB 1 1/],
        [qw/DistC DistC-0.01 AuthorC 1 1/],
      ],
    );

    no_scan_table {
      my $dist = $db->fetch_distv('DistA-0.01');
      is $dist->{distv} => 'DistA-0.01', "correct dist";
    };

    no_scan_table {
      my $dist = $db->fetch_distv('DistA');
      is $dist->{distv} => 'DistA-0.03', "correct dist";
    };

    no_scan_table {
      my $dist = $db->fetch_latest_dist('DistA');
      is $dist->{distv} => 'DistA-0.03', "latest dist is correct";
    };

    no_scan_table {
      my $dists = $db->fetch_latest_dists(qw/DistA DistB/);
      ok $dists && @$dists == 2, "num of dists is correct";
      eq_or_diff [sort map {$_->{distv}} @$dists] => [qw/DistA-0.03 DistB-0.02/], "latest dists are correct";
    };

    no_scan_table {
      my $dists = $db->fetch_dist_history('DistA');
      ok $dists && @$dists == 3, "num of dists is correct";
      eq_or_diff [map {$_->{distv}} @$dists] => [qw/DistA-0.01 DistA-0.02 DistA-0.03/], "sorted correctly";
    };
  }

  $db->remove;
}

# mark/unmark
{
  my $db = db('Kwalitee', explain => 1)->set_test_data(
    serial => 'analysis_id',
    cols => [qw/dist distv author is_cpan is_latest released/],
    rows => [
      [qw/DistA DistA-0.01 AuthorA 0 0/, epoch('2013-01-01')],
      [qw/DistA DistA-0.02 AuthorA 0 0/, epoch('2013-01-02')],
      [qw/DistA DistA-0.03 AuthorB 1 1/, epoch('2013-01-03')],
      [qw/DistB DistB-0.01 AuthorB 1 0/, epoch('2013-01-01')],
      [qw/DistB DistB-0.02 AuthorB 1 1/, epoch('2013-01-02')],
      [qw/DistC DistC-0.01 AuthorC 1 1/, epoch('2013-01-01')],
      [qw/DistD DistD-0.01 AuthorD/, undef, undef, epoch('2013-01-01')],
      [qw/DistE DistE-0.01 AuthorE 1 0/, epoch('2013-01-01')],
      [qw/DistE DistE-0.02 AuthorE 0 0/, epoch('2013-01-02')],
    ],
  );

  # is_cpan
  no_scan_table {
    my $dist = $db->fetch_distv('DistA');
    is $dist->{distv} => 'DistA-0.03', "correct dist";
    is $dist->{is_cpan} => 1, "is cpan";
  };

  no_scan_table { $db->mark_current_cpan };
  no_scan_table {
    my $dist = $db->fetch_distv('DistA');
    is $dist->{distv} => 'DistA-0.03', "correct dist";
    is $dist->{is_cpan} => 2, "flag is updated";
  };

  no_scan_table { $db->mark_cpan([qw/DistB-0.02 DistC-0.01 DistE-0.01/]) };
  no_scan_table { $db->unmark_previous_cpan };
  no_scan_table {
    my $dist = $db->fetch_distv('DistA-0.03');
    is $dist->{distv} => 'DistA-0.03', "correct dist";
    is $dist->{is_cpan} => 0, "flag is updated";
    ok $dist->{removed}, "removed time is recorded";
  };

  no_scan_table {
    my $dist = $db->fetch_distv('DistB');
    is $dist->{distv} => 'DistB-0.02', "correct dist";
    is $dist->{is_cpan} => 1, "flag is updated";
    ok !$dist->{removed}, "removed time is not recorded";
  };

  # is_latest
  no_scan_table {
    my $dist = $db->fetch_distv('DistB');
    is $dist->{distv} => 'DistB-0.02', "correct dist";
    is $dist->{is_latest} => 1, "is latest";
  };

  no_scan_table { $db->mark_current_latest };
  no_scan_table { $db->mark_latest([qw/DistC-0.01/]) };
  no_scan_table { $db->mark_implicit_latest };
  no_scan_table { $db->unmark_previous_latest };
  no_scan_table {
    my $dist = $db->fetch_distv('DistB-0.02');
    is $dist->{distv} => 'DistB-0.02', "correct dist";
    ok !$dist->{is_latest}, "is not latest";
  };

  no_scan_table {
    my $dist = $db->fetch_distv('DistC');
    is $dist->{distv} => 'DistC-0.01', "correct dist";
    is $dist->{is_latest} => 1, "is latest";
  };

  no_scan_table {
    my $dist = $db->fetch_distv('DistD-0.01');
    is $dist->{distv} => 'DistD-0.01', "correct dist";
    ok !$dist->{is_latest}, "is not latest";
  };

  no_scan_table {
    my $dist = $db->fetch_distv('DistE-0.01');
    is $dist->{distv} => 'DistE-0.01', "correct dist";
    is $dist->{is_latest} => 1, "is latest";
  };

  no_scan_table {
    my $dist = $db->fetch_distv('DistE-0.02');
    is $dist->{distv} => 'DistE-0.02', "correct dist";
    ok !$dist->{is_latest}, "is not latest";
  };

  $db->remove;
}

{ # stats
  my $db = db('Kwalitee', explain => 1)->set_test_data(
    serial => 'analysis_id',
    cols => [qw/dist distv is_cpan is_latest released/],
    rows => [
      [qw/DistA DistA-0.01 0 0/, epoch('2010-01-01')],
      [qw/DistA DistA-0.02 0 0/, epoch('2010-01-02')],
      [qw/DistA DistA-0.03 1 0/, epoch('2010-01-03')],
      [qw/DistA DistA-0.04 1 1/, epoch('2010-01-04')],
      [qw/DistB DistB-0.01 0 0/, epoch('2011-01-01')],
      [qw/DistB DistB-0.02 0 0/, epoch('2011-01-02')],
      [qw/DistB DistB-0.03 1 1/, epoch('2011-01-03')],
      [qw/AcmeC AcmeC-0.01 1 1/, epoch('2012-01-01')],
    ],
    set_metrics => 1,
  );

  no_scan_table {
    my $rows = $db->fetch_author_kwalitee('AUTHOR');
    is $rows->[0]{distv} => 'AcmeC-0.01', "first distv is correct";
    is $rows->[1]{distv} => 'DistA-0.04', "second distv is correct";
    is $rows->[2]{distv} => 'DistB-0.03', "third distv is correct";
  };

  no_scan_table {
    my $rows = $db->search_dists('D');
    eq_or_diff $rows => [qw/DistA DistB/], "found correct rows";
  }

  no_scan_table {
    my $stats = $db->fetch_overview;
    is $stats->{backpan_buildtool_not_executable} => 8, "backpan fails";
    is $stats->{cpan_buildtool_not_executable}    => 4, "cpan fails";
    is $stats->{latest_buildtool_not_executable}  => 3, "latest fails";
  }

  no_scan_table {
    my $stats = $db->fetch_indicator_stats;
    is $stats->[0]{year} => 2010, "year 2010";
    is $stats->[1]{year} => 2011, "year 2011";
    is $stats->[2]{year} => 2012, "year 2012";
    is $stats->[0]{backpan_buildtool_not_executable} => 4, "2010 backpan fails";
    is $stats->[0]{cpan_buildtool_not_executable} => 2, "2010 cpan fails";
    is $stats->[0]{latest_buildtool_not_executable} => 1, "2010 latest fails";
    is $stats->[1]{backpan_buildtool_not_executable} => 3, "2011 backpan fails";
    is $stats->[1]{cpan_buildtool_not_executable} => 1, "2011 cpan fails";
    is $stats->[1]{latest_buildtool_not_executable} => 1, "2011 latest fails";
    is $stats->[2]{backpan_buildtool_not_executable} => 1, "2012 backpan fails";
    is $stats->[2]{cpan_buildtool_not_executable} => 1, "2012 cpan fails";
    is $stats->[2]{latest_buildtool_not_executable} => 1, "2012 latest fails";
  }

  no_scan_table {
    my $dists = $db->fetch_latest_failing_dists("buildtool_not_executable");
    is @$dists => 3, "num of dists is correct";
    is $dists->[0]{distv} => 'AcmeC-0.01';
    is $dists->[1]{distv} => 'DistB-0.03';
    is $dists->[2]{distv} => 'DistA-0.04';
  };

  no_scan_table {
    $db->update_final_kwalitee($_) for (
      {analysis_id => 1, kwalitee => 120, core_kwalitee => 100},
      {analysis_id => 2, kwalitee => 110, core_kwalitee => 90},
      {analysis_id => 3, kwalitee => 100, core_kwalitee => 80},
      {analysis_id => 4, kwalitee => 120, core_kwalitee => 70},
      {analysis_id => 5, kwalitee => 80,  core_kwalitee => 60},
      {analysis_id => 6, kwalitee => 115, core_kwalitee => 95},
      {analysis_id => 7, kwalitee => 105, core_kwalitee => 85},
      {analysis_id => 8, kwalitee => 120, core_kwalitee => 75},
    );
    $db->finalize_update_final_kwalitee;

    my $dists = $db->fetch_most_kwalitative_dists;
    eq_or_diff $dists => [
      {author => 'AUTHOR', dist => 'AcmeC', kwalitee => 120},
      {author => 'AUTHOR', dist => 'DistA', kwalitee => 120},
    ], "most kwalitative dists";
  };
}

{
  my $db = db('Kwalitee', explain => 1)->set_test_data(
    serial => 'analysis_id',
    cols => [qw/dist distv is_cpan is_latest released/],
    rows => [
      [qw/DistA DistA 0 0/,      epoch('2010-01-01')],
      [qw/DistA DistA-0.02 0 1/, epoch('2010-01-02')],
    ],
    set_metrics => 1,
  );

  no_scan_table {
    my $dist = $db->fetch_distv('DistA');
    ok $dist->{is_latest};
  };
}

done_testing;
