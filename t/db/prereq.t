use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB::PrereqModules;

{
  my $db = WWW::CPANTS::DB::PrereqModules->new(explain => 1);
  $db->setup;

  my @data = (
    {
      distv => 'DistA-0.01',
      prereq => 'ModuleA',
      prereq_version => '0.01',
      type => 1,
    },
    {
      distv => 'DistA-0.01',
      prereq => 'ModuleB',
      prereq_version => '0',
      type => 1,
    },
    {
      distv => 'DistA-0.01',
      prereq => 'Test::ModuleC',
      prereq_version => '0',
      type => 2,
    },
    {
      distv => 'DistB-0.01',
      prereq => 'ModuleA',
      prereq_version => '0.01',
      type => 1,
    },
    {
      distv => 'DistB-0.01',
      prereq => 'ModuleD',
      prereq_version => '0',
      type => 1,
    },
    {
      distv => 'DistB-0.01',
      prereq => 'Test::ModuleC',
      prereq_version => '0',
      type => 2,
    },
    {
      distv => 'DistB-0.01',
      prereq => 'Test::ModuleE',
      prereq_version => '0',
      type => 2,
    },
  );

  for (0..1) { # repetition doesn't break things?
    for (@data) {
      $db->bulk_insert($_);
    }
    $db->finalize_bulk_insert;

    {
      my $prereqs = $db->fetch_all_prereqs;
      eq_or_diff [sort @$prereqs] => [qw/ModuleA ModuleB ModuleD Test::ModuleC Test::ModuleE/], "correct prereqs";
    }

    {
      my %mapping = (
        ModuleA => 'DistA',
        ModuleB => 'DistA',
        ModuleD => 'DistD',
        'Test::ModuleC' => 'TestDistC',
        'Test::ModuleE' => 'TestDistE',
      );
      for (keys %mapping) {
        $db->update_prereq_dist($_ => $mapping{$_});
      }
      my $dists = $db->fetchall_prereq_dists;
      eq_or_diff [sort @$dists] => [qw/DistA DistD TestDistC TestDistE/], "correct prereq dists";
    }

    {
      my $dists = $db->fetch_prereqs_of('DistA-0.01');
      eq_or_diff [sort {$a->{prereq_dist} cmp $b->{prereq_dist}} @$dists] => [
        {prereq_dist => 'DistA', type => 1},
        {prereq_dist => 'TestDistC', type => 2},
      ], "correct prereq dists of DistA-0.01";
    }
  }

  $db->remove;
}

{
  my $db = WWW::CPANTS::DB::PrereqModules->new(explain => 1);
  $db->setup;

  {
    my $count = $db->fetch_1('select count(*) from prereq');
    is $count => 0, "num of rows is correct";
  }

  for (0..2000) {
    $db->bulk_insert({
      distv => "Dist$_",
      prereq => "ModuleA",
      prereq_version => "0.01",
      type => 1,
    });
  }
  $db->finalize_bulk_insert;

  {
    my $count = $db->fetch_1('select count(*) from prereq');
    is $count => 2001, "num of rows is correct: $count";
  }

  $db->remove;
}

done_testing;
