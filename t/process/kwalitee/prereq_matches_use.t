use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;
use WWW::CPANTS::Process::Kwalitee::PrereqMatchesUse;

{
  db('Kwalitee')->set_test_data(
    cols => [qw/analysis_id distv/],
    rows => [
      [qw/1 DistA-0.01/],
      [qw/2 DistB-0.01/],
      [qw/3 DistC-0.01/],
    ],
  );

  db('UsedModules')->set_test_data(
    cols => [qw/distv module module_dist in_code in_tests/],
    rows => [
      [qw/DistA-0.01 ModuleA ModDistA 1 0/],
      [qw/DistA-0.01 ModuleB ModDistB 1 0/],
      [qw/DistA-0.01 ModuleC ModDistC 0 1/],
      [qw/DistA-0.01 Exporter Exporter 1 0/],  # core
      [qw/DistA-0.01 DB_File perl 0 1/],       # core

      [qw/DistB-0.01 ModuleA ModDistA 1 0/],
      [qw/DistB-0.01 ModuleB ModDistB 1 0/],
      [qw/DistB-0.01 ModuleC ModDistC 1 0/],

      [qw/DistC-0.01 ModuleA ModDistA 0 1/],
      [qw/DistC-0.01 ModuleB ModDistB 0 1/],
      [qw/DistC-0.01 ModuleC ModDistC 0 1/],

    ],
  );

  db('PrereqModules')->set_test_data(
    cols => [qw/distv prereq_dist type/],
    rows => [
      [qw/DistA-0.01 ModDistA 1/],
      [qw/DistA-0.01 ModDistB 3/], # recommended
      [qw/DistA-0.01 ModDistC 2/],

      [qw/DistB-0.01 ModDistA 1/],
      [qw/DistB-0.01 ModDistC 2/], # build_prereq, not used

      [qw/DistC-0.01 ModDistA 1/], # prereq, not used
      [qw/DistC-0.01 ModDistC 2/],
    ],
  );

  db('Errors')->setup;
}

WWW::CPANTS::Process::Kwalitee::PrereqMatchesUse->new->update;

{
  my $kwalitee_db = db('Kwalitee');
  my $errors_db = db('Errors');

  {
    my $dist_a = $kwalitee_db->fetch("select * from kwalitee where distv = ?", "DistA-0.01");
    is $dist_a->{prereq_matches_use} => 1, "dist_a: prereq matches use";
    is $dist_a->{build_prereq_matches_use} => 1, "dist_a: build_prereq matches use";

    my $errors_a = $errors_db->fetchall("select * from errors where distv = ?", "DistA-0.01");
    ok !@$errors_a, "no errors";
  }

  {
    my $dist_b = $kwalitee_db->fetch("select * from kwalitee where distv = ?", "DistB-0.01");
    is $dist_b->{prereq_matches_use} => 0, "dist_b: prereq matches use";
    is $dist_b->{build_prereq_matches_use} => 1, "dist_b: build_prereq matches use";

    my $errors_b = $errors_db->fetchall("select * from errors where distv = ?", "DistB-0.01");
    ok @$errors_b, "has error(s)";
    is $errors_b->[0]{error} => 'ModDistB,ModDistC', "correct error";
  }

  {
    my $dist_c = $kwalitee_db->fetch("select * from kwalitee where distv = ?", "DistC-0.01");
    is $dist_c->{prereq_matches_use} => 1, "dist_c: prereq matches use";
    is $dist_c->{build_prereq_matches_use} => 0, "dist_c: build_prereq matches use";

    my $errors_c = $errors_db->fetchall("select * from errors where distv = ?", "DistC-0.01");
    ok @$errors_c, "has error(s)";
    is $errors_c->[0]{error} => 'ModDistB', "correct error";
  }
}

done_testing;
