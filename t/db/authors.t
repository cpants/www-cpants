use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;

{
  my $db = db('Authors', explain => 1);

  for (0..1) { # repetition doesn't break things?
    $db->set_test_data(
      cols => [qw/pauseid name email/],
      rows => [
        [qw/AUTHOR name_a email_a/],
        [qw/BUTHOR name_b email_b/],
        [qw/CUTHOR name_c email_c/],
      ]
    );

    my @data = (
      {
         num_dists => 5,
         average_kwalitee => 120,
         average_core_kwalitee => 95,
         pauseid => 'AUTHOR',
      },
      {
         num_dists => 5,
         average_kwalitee => 100,
         average_core_kwalitee => 90,
         pauseid => 'BUTHOR',
      },
      {
         num_dists => 2,
         average_kwalitee => 130,
         average_core_kwalitee => 100,
         pauseid => 'CUTHOR',
      },
    );

    $db->update_author_stats(\@data);

    no_scan_table {
      my $rank = $db->fetch_five_or_more_dists_ranking;
      is @{$rank->{rows}} => 2, "num of authors with five or more dists";
      is $rank->{rows}[0]{pauseid} => 'AUTHOR';
      is $rank->{rows}[1]{pauseid} => 'BUTHOR';
    };
    no_scan_table {
      my $rank = $db->fetch_less_than_five_dists_ranking;
      is @{$rank->{rows}} => 1, "num of authors with less than five dists";
      is $rank->{rows}[0]{pauseid} => 'CUTHOR';
    };

    no_scan_table {
      my $authors = $db->search_authors("A");
      is @$authors => 1;
      is $authors->[0]{pauseid} => 'AUTHOR';
    } "search_authors is currently known to be slow";

    no_scan_table {
      my $author = $db->fetch_author("AUTHOR");
      is $author->{pauseid} => 'AUTHOR';
    };

    no_scan_table {
      my $count = $db->count_authors;
      ok $count, "count authors";
    };

    no_scan_table {
      my $count = $db->count_contributed_authors;
      ok $count, "count contributed authors";
    };

    no_scan_table {
      my $authors = $db->fetch_most_contributed_authors;
      ok @$authors, "most contributed authors";
      ok $authors->[-1]{rank} < 100, "lowest rank should be less than 100";
    };
  }
}

done_testing;
