use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB::Uploads;

{
  my $db = WWW::CPANTS::DB::Uploads->new(explain => 1);
  $db->setup;

  # uploads.db is a borrowed db, so there's no bulk_insert API.
  {
    my @data = (
      [qw/backpan DistA 0.01 100/],
      [qw/cpan    DistA 0.02 200/],
      [qw/cpan    DistA 0.03 300/],
      [qw/backpan DistB 0.01 400/],
      [qw/cpan    DistB 0.02 500/],
      [qw/backpan DistB 0.03 600/],
      [qw/backpan DistC 0.01 700/],
      [qw/backpan DistC 0.02 800/],
      [qw/backpan DistC 0.03 900/],
    );
    $db->bulk('insert into uploads (type, dist, version, released) values (?, ?, ?, ?)', \@data);
  }

  {
    my $dists = $db->latest_dists;
    eq_or_diff $dists => [qw/DistA-0.03 DistB-0.02/], "correct latest dists";
  }
}

done_testing;
