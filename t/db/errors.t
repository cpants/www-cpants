use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;

{
  my $db = db('Errors', explain => 1);

  for (0..1) { # repetition doesn't break things?
    $db->set_test_data(
      cols => [qw/analysis_id distv category error/],
      rows => [
        [qw/1 DistA-0.01 category1 errorA/],
        [qw/1 DistA-0.01 category2 errorB/],
        [qw/2 DistB-0.01 category1 errorC/],
        [qw/3 DistB-0.02 category2 errorD/],
      ],
    );

    no_scan_table {
      my $errors = $db->fetch_distv_errors(1); # DistA-0.01
      eq_or_diff $errors => [
        {category => 'category1', error => 'errorA'},
        {category => 'category2', error => 'errorB'},
      ], "DistA-0.01 errors";
    };

    no_scan_table {
      my $errors = $db->fetch_distv_errors(2); # DistB-0.01
      eq_or_diff $errors => [
        {category => 'category1', error => 'errorC'},
      ], "DistB-0.01 errors";
    };

    no_scan_table {
      my $errors = $db->fetch_category_errors('category1');
      eq_or_diff $errors => [
        {distv => 'DistA-0.01', error => 'errorA'},
        {distv => 'DistB-0.01', error => 'errorC'},
      ], "category1 errors";
    };
  }

  no_scan_table {
    $db->mark(qw/category1/);

    $db->bulk_insert({
      analysis_id => 2,
      distv => 'DistB-0.01',
      category => 'category1',
      error => 'errorC',
    });
    $db->finalize_bulk_insert;

    $db->unmark(qw/category1/);
  };

  no_scan_table {
    my $errors = $db->fetch_category_errors('category1');
    eq_or_diff $errors => [
      {distv => 'DistB-0.01', error => 'errorC'},
    ], "category1 errors";
  };

  no_scan_table {
    my $errors = $db->fetch_category_errors('category2');
    eq_or_diff $errors => [
      {distv => 'DistA-0.01', error => 'errorB'},
      {distv => 'DistB-0.02', error => 'errorD'},
    ], "category2 errors";
  };

  $db->remove;
}

done_testing;
