use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB::Errors;

{
  my $db = WWW::CPANTS::DB::Errors->new(explain => 1);
  $db->setup;

  my @data = (
    {
      distv => 'DistA-0.01',
      category => 'category1',
      error => 'errorA',
    },
    {
      distv => 'DistA-0.01',
      category => 'category2',
      error => 'errorB',
    },
    {
      distv => 'DistB-0.01',
      category => 'category1',
      error => 'errorC',
    },
    {
      distv => 'DistB-0.02',
      category => 'category2',
      error => 'errorD',
    },
  );

  for (0..1) { # repetition doesn't break things?
    for (@data) {
      $db->bulk_insert($_);
    }
    $db->finalize_bulk_insert;

    {
      my $errors = $db->fetch_distv_errors('DistA-0.01');
      eq_or_diff $errors => [
        {category => 'category1', error => 'errorA'},
        {category => 'category2', error => 'errorB'},
      ], "DistA-0.01 errors";
    }

    {
      my $errors = $db->fetch_distv_errors('DistB-0.01');
      eq_or_diff $errors => [
        {category => 'category1', error => 'errorC'},
      ], "DistB-0.01 errors";
    }

    {
      my $errors = $db->fetch_category_errors('category1');
      eq_or_diff $errors => [
        {distv => 'DistA-0.01', error => 'errorA'},
        {distv => 'DistB-0.01', error => 'errorC'},
      ], "category1 errors";
    }
  }

  $db->remove;
}

{
  my $db = WWW::CPANTS::DB::Errors->new(explain => 1);
  $db->setup;

  {
    my $count = $db->fetch_1('select count(*) from errors');
    is $count => 0, "num of rows is correct";
  }

  for (0..2000) {
    $db->bulk_insert({
      distv => "Dist$_-0.01",
      category => "Error",
      error => "Error",
    });
  }
  $db->finalize_bulk_insert;

  {
    my $count = $db->fetch_1('select count(*) from errors');
    is $count => 2001, "num of rows is correct: $count";
  }

  $db->remove;
}

done_testing;
