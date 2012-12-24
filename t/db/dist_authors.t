use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;

{
  my $db = db('DistAuthors', explain => 1);

  for (0..1) { # repetition doesn't break things?
    $db->set_test_data(
      cols => [qw/dist author/],
      rows => [
        [qw/DistA AuthorA/],
        [qw/DistA AuthorB/],
        [qw/DistA AuthorC/],
        [qw/DistB AuthorB/],
        [qw/DistB AuthorB/],
      ],
    );

    no_scan_table {
      my $authors = $db->fetch_authors('DistA');
      eq_or_diff $authors => [qw/AuthorA AuthorB AuthorC/], "DistA is maintained by AuthorA/B/C";
    };

    no_scan_table {
      my $authors = $db->fetch_authors('DistB');
      eq_or_diff $authors => [qw/AuthorB/], "DistB is maintained solely by AuthorB";
    };
  }

  $db->remove;
}

done_testing;
