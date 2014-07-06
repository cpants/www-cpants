use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;
use WWW::CPANTS::Process::Kwalitee::IsCPAN;

{
  db('Uploads')->set_test_data(
    cols => [qw/type dist version released/],
    rows => [
      [qw/backpan DistA 0.01/, epoch('2012-01-01')],
      [qw/cpan    DistA 0.02/, epoch('2012-01-02')],
      [qw/cpan    DistA 0.03/, epoch('2012-01-03')],
    ],
  );

  db('Kwalitee')->set_test_data(
    cols => [qw/analysis_id dist distv/],
    rows => [
      [qw/1 DistA DistA-0.01/],
      [qw/2 DistA DistA-0.02/],
      [qw/3 DistA DistA-0.03/],
    ],
  );
}

WWW::CPANTS::Process::Kwalitee::IsCPAN->new->update;

{
  my $kwalitee_db = db('Kwalitee');
  my @rows;
  while (my $row = $kwalitee_db->iterate(qw/distv is_cpan is_latest/)) {
    push @rows, $row;
  }
  is @rows => 3, "got 3 rows";
  is $rows[0]{distv} => 'DistA-0.01', "1st row is correct";
  is $rows[1]{distv} => 'DistA-0.02', "2nd row is correct";
  is $rows[2]{distv} => 'DistA-0.03', "3rd row is correct";

  ok !$rows[0]{is_cpan}, 'DistA-0.01 is not on the cpan';
  ok $rows[1]{is_cpan}, 'DistA-0.02 is on the cpan';
  ok $rows[2]{is_cpan}, 'DistA-0.03 is on the cpan';

  ok !$rows[0]{is_latest}, 'DistA-0.01 is not the latest';
  ok !$rows[1]{is_latest}, 'DistA-0.02 is not the latest';
  ok $rows[2]{is_latest}, 'DistA-0.03 is the latest';
}

{
  db('Uploads')->set_test_data(
    clean => 1,
    cols => [qw/type dist version released/],
    rows => [
      [qw/backpan DistA 0.01/, epoch('2012-01-01')],
      [qw/cpan    DistA 0.02/, epoch('2012-01-02')],
      [qw/backpan DistA 0.03/, epoch('2012-01-03')],
      [qw/cpan    DistA 0.04/, epoch('2012-01-04')],
    ],
  );
}

WWW::CPANTS::Process::Kwalitee::IsCPAN->new->update;

{
  my $kwalitee_db = db('Kwalitee');
  my @rows;
  while (my $row = $kwalitee_db->iterate(qw/distv is_cpan is_latest/)) {
    push @rows, $row;
  }
  is @rows => 3, "got 3 rows";
  is $rows[0]{distv} => 'DistA-0.01', "1st row is correct";
  is $rows[1]{distv} => 'DistA-0.02', "2nd row is correct";
  is $rows[2]{distv} => 'DistA-0.03', "3rd row is correct";

  ok !$rows[0]{is_cpan}, 'DistA-0.01 is not on the cpan';
  ok $rows[1]{is_cpan}, 'DistA-0.02 is on the cpan';
  ok !$rows[2]{is_cpan}, 'DistA-0.03 is not on the cpan';

  ok !$rows[0]{is_latest}, 'DistA-0.01 is not the latest';
  ok $rows[1]{is_latest}, 'DistA-0.02 is the latest (until 0.04 is processed)';
  ok !$rows[2]{is_latest}, 'DistA-0.03 is not the latest';
}

{
  db('Kwalitee')->set_test_data(
    cols => [qw/analysis_id dist distv/],
    rows => [
      [qw/4 DistA DistA-0.04/],
    ],
  );
}

WWW::CPANTS::Process::Kwalitee::IsCPAN->new->update;

{
  my $kwalitee_db = db('Kwalitee');
  my @rows;
  while (my $row = $kwalitee_db->iterate(qw/distv is_cpan is_latest/)) {
    push @rows, $row;
  }
  is @rows => 4, "got 4 rows";
  is $rows[0]{distv} => 'DistA-0.01', "1st row is correct";
  is $rows[1]{distv} => 'DistA-0.02', "2nd row is correct";
  is $rows[2]{distv} => 'DistA-0.03', "3rd row is correct";
  is $rows[3]{distv} => 'DistA-0.04', "4th row is correct";

  ok !$rows[0]{is_cpan}, 'DistA-0.01 is not on the cpan';
  ok $rows[1]{is_cpan}, 'DistA-0.02 is on the cpan';
  ok !$rows[2]{is_cpan}, 'DistA-0.03 is not on the cpan';
  ok $rows[3]{is_cpan}, 'DistA-0.04 is on the cpan';

  ok !$rows[0]{is_latest}, 'DistA-0.01 is not the latest';
  ok !$rows[1]{is_latest}, 'DistA-0.02 is not the latest';
  ok !$rows[2]{is_latest}, 'DistA-0.03 is not the latest';
  ok $rows[3]{is_latest}, 'DistA-0.04 is the latest';
}

done_testing;
