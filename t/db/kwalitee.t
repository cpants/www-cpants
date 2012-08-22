use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB::Kwalitee;

{
  my $db = WWW::CPANTS::DB::Kwalitee->new(explain => 1);
  $db->setup;

  my @data = (
    {
      analysis_id => 1,
      dist => 'DistA',
      distv => 'DistA-0.01',
      author => 'AuthorA',
    },
    {
      analysis_id => 2,
      dist => 'DistA',
      distv => 'DistA-0.02',
      author => 'AuthorA',
    },
    {
      analysis_id => 3,
      dist => 'DistA',
      distv => 'DistA-0.03',
      author => 'AuthorB',
    },
    {
      analysis_id => 4,
      dist => 'DistB',
      distv => 'DistB-0.01',
      author => 'AuthorB',
    },
    {
      analysis_id => 5,
      dist => 'DistB',
      distv => 'DistB-0.02',
      author => 'AuthorB',
    },
    {
      analysis_id => 6,
      dist => 'DistC',
      distv => 'DistC-0.01',
      author => 'AuthorC',
    },
  );

  for (0..1) { # repetition doesn't break things?
    for (@data) {
      $db->bulk_insert($_);
    }
    $db->finalize_bulk_insert;

  }

  $db->remove;
}

{
  my $db = WWW::CPANTS::DB::Kwalitee->new(explain => 1);
  $db->setup;

  {
    my $count = $db->fetch_1('select count(*) from kwalitee');
    is $count => 0, "num of rows is correct";
  }

  for (0..2000) {
    $db->bulk_insert({
      analysis_id => $_,
    });
  }
  $db->finalize_bulk_insert;

  {
    my $count = $db->fetch_1('select count(*) from kwalitee');
    is $count => 2001, "num of rows is correct: $count";
  }

  $db->remove;
}

done_testing;
