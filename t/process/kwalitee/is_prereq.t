use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;
use WWW::CPANTS::Process::Kwalitee::IsPrereq;

{
  db('PrereqModules')->set_test_data(
    cols => [qw/dist distv author prereq prereq_version prereq_dist type/],
    rows => [
      [qw/DistA DistA-0.01 AuthorA ModuleB 0 DistB 1/],
      [qw/DistA DistA-0.01 AuthorA ModuleC 0 DistC 1/],
    ],
  );

  db('Kwalitee')->set_test_data(
    cols => [qw/analysis_id dist distv author/],
    rows => [
      [qw/1 DistA DistA-0.01 AuthorA/],
      [qw/2 DistB DistB-0.01 AuthorB/],
      [qw/3 DistC DistC-0.01 AuthorA/],
    ]
  );
}

WWW::CPANTS::Process::Kwalitee::IsPrereq->new->update;

{
  my $kwalitee_db = db('Kwalitee');

  my $dist_a = $kwalitee_db->fetch_distv('DistA-0.01');
  ok !$dist_a->{is_prereq};

  # "required by a distribution by another author" should be counted.
  my $dist_b = $kwalitee_db->fetch_distv('DistB-0.01');
  ok $dist_b->{is_prereq};

  # "required by a distribution by the same author" shouldn't be counted.
  my $dist_c = $kwalitee_db->fetch_distv('DistC-0.01');
  ok !$dist_c->{is_prereq};
#  note explain $_ while $_= $kwalitee_db->iterate;
}

done_testing;
