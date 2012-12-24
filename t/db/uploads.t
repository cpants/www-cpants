use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;
use Time::Piece;

{
  my $db = db('Uploads', explain => 1)->set_test_data(
    cols => [qw/type dist author version released/],
    rows => [
      [qw/backpan DistA AuthorA 0.01/, epoch('2010-01-01')],
      [qw/cpan    DistA AuthorA 0.02/, epoch('2010-01-02')],
      [qw/cpan    DistA AuthorA 0.30/, epoch('2010-01-03')],
      [qw/backpan DistB AuthorB 0.01/, epoch('2011-01-04')],
      [qw/cpan    DistB AuthorB 0.02/, epoch('2011-01-05')],
      [qw/backpan DistB AuthorB 0.03/, epoch('2011-01-06')],
      [qw/backpan DistC AuthorC 0.01/, epoch('2011-01-07')],
      [qw/backpan DistC AuthorB 0.02/, epoch('2011-01-08')],
      [qw/backpan DistC AuthorA 0.03/, epoch('2012-01-09')],
      [qw/cpan    DistD AuthorD 0.01_01   /, epoch('2012-01-10')],
      [qw/cpan    DistD AuthorE 0.02      /, epoch('2012-01-11')],
      [qw/cpan    DistD AuthorE 0.03_01   /, epoch('2012-01-12')],
      [qw/cpan    DistD AuthorD 0.04-TRIAL/, epoch('2012-01-13')],
    ],
  );

  no_scan_table {
    my @dists = $db->cpan_dists;
    eq_or_diff \@dists => [qw/DistA-0.02 DistA-0.30 DistB-0.02 DistD-0.01_01 DistD-0.02 DistD-0.03_01 DistD-0.04-TRIAL/], "correct cpan dists";
  };

  no_scan_table {
    my @dists = $db->latest_dists;
    eq_or_diff \@dists => [qw/DistA-0.30 DistB-0.02 DistD-0.04-TRIAL/], "correct latest dists";
  };

  no_scan_table {
    my @dists = $db->latest_stable_dists;
    eq_or_diff \@dists => [qw/DistA-0.30 DistB-0.02 DistD-0.02/], "correct latest stable dists";
  };

  no_scan_table {
    my @years = $db->count_active_authors_per_year;
    eq_or_diff \@years => [
      {year => 2010, authors => 1},
      {year => 2011, authors => 2},
      {year => 2012, authors => 3},
    ], "active authors are correct";
  };

  no_scan_table {
    my $count = $db->count_distinct_dists;
    is $count => 4, "4 distinct dists";
  } "maybe slow";

  no_scan_table {
    my $count = $db->count_distinct_dists('cpan');
    is $count => 3, "3 distinct CPAN dists";
  };

  no_scan_table {
    my $count = $db->count_uploads;
    is $count => 13, "13 uploads";
  };

  no_scan_table {
    my @years = $db->count_uploads_per_year;
    eq_or_diff \@years => [
      {year => 2010, uploads => 3, new_uploads => 1, is_cpan => 2},
      {year => 2011, uploads => 5, new_uploads => 2, is_cpan => 1},
      {year => 2012, uploads => 5, new_uploads => 1, is_cpan => 4},
    ], "uploads are correct";
  };

  no_scan_table {
    my $uploads = $db->fetch_most_often_uploaded;
    eq_or_diff $uploads => [
      {dist => 'DistD', authors => 'AuthorD,AuthorE', uploads => 4, rank => 1},
      {dist => 'DistA', authors => 'AuthorA', uploads => 3, rank => 2},
      {dist => 'DistB', authors => 'AuthorB', uploads => 3, rank => 2},
      {dist => 'DistC', authors => 'AuthorC,AuthorB,AuthorA', uploads => 3, rank => 2},
 
    ], "uploads are correct";
  };

  no_scan_table {
    my $path = 'A/Au/AuthorA/DistA-0.02.tar.gz';
    my $type = $db->fetch_current_type($path);
    is $type => 'cpan', "correct type";

    $db->update_type('backpan', $path);
    $db->finalize_update_type;

    $type = $db->fetch_current_type($path);
    is $type => 'backpan', "correct type";
  };

  { # tailing 0
    my $version = $db->fetch_1("select version from uploads where distv = ?", 'DistA-0.30');
    is $version => '0.30', "tailing 0 is not removed";
  }
}

done_testing;
