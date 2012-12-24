use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;
use WWW::CPANTS::Process::Kwalitee::PrereqDist;

{
  db('PrereqModules')->set_test_data(
    cols => [qw/prereq/],
    rows => [
      # core-only
      [qw/Fcntl/],

      # dual-life
      [qw/ExtUtils::MakeMaker/],

      # CPAN
      [qw/Moose/],

      # broken
      [qw/NoSuchModule/],
    ]
  );

  db('DistModules')->set_test_data(
    cols => [qw/dist module released/],
    rows => [
      [qw/ExtUtils-MakeMaker ExtUtils::MakeMaker 10/],
      [qw/Build-Daily ExtUtils::MakeMaker 5/],
      [qw/Moose Moose 5/],
    ]
  );

  db('Packages')->set_test_data(
    cols => [qw/module dist/],
    rows => [
      [qw/ExtUtils::MakeMaker ExtUtils-MakeMaker/],
      [qw/Encode Encode/],
      [qw/Fcntl perl/],
      [qw/Moose Moose/],
    ]
  );
}

WWW::CPANTS::Process::Kwalitee::PrereqDist->new->update;

{
  my $prereq_db = db('PrereqModules');

  my %expected = (
    Fcntl => 'perl',
    Moose => 'Moose',
    'ExtUtils::MakeMaker' => 'ExtUtils-MakeMaker',
    NoSuchModule => '',
  );

  for (keys %expected) {
    my $dist = $prereq_db->fetch_1("select prereq_dist from prereq_modules where prereq = ?", $_);
    is $dist => $expected{$_}, "$_ belongs to $expected{$_}";
  }
}

done_testing;
