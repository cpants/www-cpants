use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB::DistModules;

{
  my $db = WWW::CPANTS::DB::DistModules->new(explain => 1);
  $db->setup;

  my @data = (
    {
      dist => 'DistA',
      distv => 'DistA-0.01',
      modules => [qw/ModuleA ModuleB ModuleC/],
      released => 100,
    },
    {
      dist => 'DistB',
      distv => 'DistB-0.01',
      modules => [qw/ModuleE/],
      released => 150,
    },
    {
      dist => 'DistA',
      distv => 'DistA-0.02',
      modules => [qw/ModuleA ModuleB ModuleC ModuleD/],
      released => 200,
    },
    {
      dist => 'DistB',
      distv => 'DistB-0.02',
      modules => [qw/ModuleA ModuleE/],
      released => 250,
    },
    {
      dist => 'DistA',
      distv => 'DistA-0.03',
      modules => [qw/ModuleB ModuleC ModuleD/],
      released => 300,
    },
  );

  for (0..1) { # repetition doesn't break things?
    for my $dist (@data) {
      for (@{$dist->{modules}}) {
        $db->bulk_insert({
          dist  => $dist->{dist},
          distv => $dist->{distv},
          module => $_,
          released => $dist->{released},
        });
      }
    }
    $db->finalize_bulk_insert;

    {
      my $dists = $db->dists_by_modules([qw/ModuleA/]);
      eq_or_diff $dists => [qw/DistB/], "ModuleA belongs to DistB now";
    }

    {
      my $dists = $db->dists_by_modules([qw/ModuleB/]);
      eq_or_diff $dists => [qw/DistA/], "ModuleB belongs to DistA";
    }

    {
      my $dists = $db->dists_by_modules([qw/ModuleB ModuleC/]);
      eq_or_diff $dists => [qw/DistA/], "Both ModuleB and ModuleC belong to DistA";
    }

    {
      my $dists = $db->dists_by_modules([qw/ModuleA ModuleC/]);
      eq_or_diff $dists => [qw/DistA DistB/], "ModuleA belongs to DistB and ModuleC belong to DistA";
    }

    {
      my $dists = $db->dists_by_modules([qw/ModuleA ModuleE/]);
      eq_or_diff $dists => [qw/DistB/], "Both ModuleA and ModuleD belong to DistB";
    }
  }

  $db->remove;
}

{
  my $db = WWW::CPANTS::DB::DistModules->new(explain => 1);
  $db->setup;

  {
    my $count = $db->fetch_1('select count(*) from dist_modules');
    is $count => 0, "num of rows is correct";
  }

  for (0..2000) {
    $db->bulk_insert({
      dist => 'DistA',
      distv => 'DistA-0.01',
      module => "Module$_",
      version => 0,
      released => 0,
    });
  }
  $db->finalize_bulk_insert;

  {
    my $count = $db->fetch_1('select count(*) from dist_modules');
    is $count => 2001, "num of rows is correct: $count";
  }

  $db->remove;
}

done_testing;
