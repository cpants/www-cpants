use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;
use WWW::CPANTS::Process::Kwalitee::AuthorStats;

{
  db('Kwalitee')->set_test_data(
    cols => [qw/analysis_id dist distv author released is_cpan kwalitee core_kwalitee/],
    rows => [
      [qw/1 DistA DistA-0.01 AuthorA 1 1 120 100/],
      [qw/2 DistA DistA-0.02 AuthorA 2 1 120 100/],
      [qw/3 DistB DistB-0.01 AuthorA 1 1 100 80/],
      [qw/4 DistC DistC-0.01 AuthorA 1 0 30 20/],
      [qw/5 DistC DistC-0.02 AuthorA 1 1 50 30/],

      [qw/6 DistD DistD-0.01 AuthorB 1 1 130 110/],
      [qw/7 DistD DistD-0.02 AuthorB 2 1 130 110/],
      [qw/8 DistE DistE-0.01 AuthorB 1 1 110 90/],
      [qw/9 DistF DistF-0.01 AuthorB 1 0 40 30/],
      [qw/10 DistF DistF-0.02 AuthorB 1 1 60 40/],

      [qw/11 DistG DistG-0.01 AuthorC 1 1 120 100/],
      [qw/12 DistH DistH-0.02 AuthorC 2 1 120 100/],
      [qw/13 DistI DistI-0.01 AuthorC 1 1 100 80/],
      [qw/14 DistJ DistJ-0.01 AuthorC 1 1 30 20/],
      [qw/15 DistK DistK-0.02 AuthorC 1 1 50 30/],

      [qw/16 DistL DistL-0.01 AuthorD 1 1 130 110/],
      [qw/17 DistM DistM-0.02 AuthorD 2 1 130 110/],
      [qw/18 DistN DistN-0.01 AuthorD 1 1 110 90/],
      [qw/19 DistO DistO-0.01 AuthorD 1 1 40 30/],
      [qw/20 DistP DistP-0.02 AuthorD 1 1 60 40/],
    ]
  );

  db('Authors')->set_test_data(
    cols => [qw/pauseid/],
    rows => [
      [qw/AuthorA/],
      [qw/AuthorB/],
      [qw/AuthorC/],
      [qw/AuthorD/],
    ]
  );
}

WWW::CPANTS::Process::Kwalitee::AuthorStats->new->update;

{
  my $authors_db = db('Authors');

  {
    my $author_a = $authors_db->fetch("select * from authors where pauseid = ?", "AuthorA");
    is $author_a->{num_dists} => 3, "num of dists is correct";
    is $author_a->{liga} => 0, "liga is correct";
    is $author_a->{rank} => 2, "rank is correct";
    is $author_a->{average_core_kwalitee} => 70, "average core kwalitee is correct";
    is $author_a->{average_kwalitee} => 90, "average kwalitee is correct";
    #note explain $author_a;
  }

  {
    my $author_b = $authors_db->fetch("select * from authors where pauseid = ?", "AuthorB");
    is $author_b->{num_dists} => 3, "num of dists is correct";
    is $author_b->{liga} => 0, "liga is correct";
    is $author_b->{rank} => 1, "rank is correct";
    is $author_b->{average_core_kwalitee} => 80, "average core kwalitee is correct";
    is $author_b->{average_kwalitee} => 100, "average kwalitee is correct";
    #note explain $author_b;
  }

  {
    my $author_c = $authors_db->fetch("select * from authors where pauseid = ?", "AuthorC");
    is $author_c->{num_dists} => 5, "num of dists is correct";
    is $author_c->{liga} => 1, "liga is correct";
    is $author_c->{rank} => 2, "rank is correct";
    is $author_c->{average_core_kwalitee} => 66, "average core kwalitee is correct";
    is $author_c->{average_kwalitee} => 84, "average kwalitee is correct";
    #note explain $author_c;
  }

  {
    my $author_d = $authors_db->fetch("select * from authors where pauseid = ?", "AuthorD");
    is $author_d->{num_dists} => 5, "num of dists is correct";
    is $author_d->{liga} => 1, "liga is correct";
    is $author_d->{rank} => 1, "rank is correct";
    is $author_d->{average_core_kwalitee} => 76, "average core kwalitee is correct";
    is $author_d->{average_kwalitee} => 94, "average kwalitee is correct";
    #note explain $author_d;
  }
}

done_testing;
