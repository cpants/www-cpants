use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB::DistAuthors;

{
  my $db = WWW::CPANTS::DB::DistAuthors->new(explain => 1);
  $db->setup;

  my @data = (
    {
      dist => 'DistA',
      author => 'AuthorA',
    },
    {
      dist => 'DistA',
      author => 'AuthorB',
    },
    {
      dist => 'DistA',
      author => 'AuthorC',
    },
    {
      dist => 'DistB',
      author => 'AuthorB',
    },
    {
      dist => 'DistB',
      author => 'AuthorB',
    },
  );

  for (0..1) { # repetition doesn't break things?
    for (@data) {
      $db->bulk_insert($_);
    }
    $db->finalize_bulk_insert;

    {
      my $authors = $db->fetch_authors('DistA');
      eq_or_diff $authors => [qw/AuthorA AuthorB AuthorC/], "DistA is maintained by AuthorA/B/C";
    }

    {
      my $authors = $db->fetch_authors('DistB');
      eq_or_diff $authors => [qw/AuthorB/], "DistB is maintained solely by AuthorB";
    }
  }

  $db->remove;
}

{
  my $db = WWW::CPANTS::DB::DistAuthors->new(explain => 1);
  $db->setup;

  {
    my $count = $db->fetch_1('select count(*) from dist_authors');
    is $count => 0, "num of rows is correct";
  }

  for (0..2000) {
    $db->bulk_insert({
      dist => 'DistA',
      author => "Author$_",
    });
  }
  $db->finalize_bulk_insert;

  {
    my $count = $db->fetch_1('select count(*) from dist_authors');
    is $count => 2001, "num of rows is correct: $count";
  }

  $db->remove;
}

done_testing;
