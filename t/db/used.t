use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB::UsedModules;

{
  my $db = WWW::CPANTS::DB::UsedModules->new(explain => 1);
  $db->setup;

  my @data = (
    {
      distv => 'DistA-0.01',
      module => 'ModuleA',
      in_code => 1,
      in_tests => 1,
    },
    {
      distv => 'DistA-0.01',
      module => 'ModuleB',
      in_code => 1,
      in_tests => 0,
    },
    {
      distv => 'DistA-0.01',
      module => 'Test::ModuleC',
      in_code => 0,
      in_tests => 2,
    },
    {
      distv => 'DistB-0.01',
      module => 'ModuleA',
      in_code => 1,
      in_tests => 1,
    },
    {
      distv => 'DistB-0.01',
      module => 'ModuleD',
      in_code => 1,
      in_tests => 0,
    },
    {
      distv => 'DistB-0.01',
      module => 'Test::ModuleC',
      in_code => 0,
      in_tests => 2,
    },
    {
      distv => 'DistB-0.01',
      module => 'Test::ModuleE',
      in_code => 0,
      in_tests => 2,
    },
  );

  for (0..1) { # repetition doesn't break things?
    for (@data) {
      $db->bulk_insert($_);
    }
    $db->finalize_bulk_insert;

    {
      my $modules = $db->fetch_all_used_modules;
      eq_or_diff [sort @$modules] => [qw/ModuleA ModuleB ModuleD Test::ModuleC Test::ModuleE/], "correct modules";
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
        $db->update_used_module_dist($_ => $mapping{$_});
      }
      my $dists = $db->fetchall_1('select distinct(module_dist) from used_modules');
      eq_or_diff [sort @$dists] => [qw/DistA DistD TestDistC TestDistE/], "correct used dists";
    }

    {
      my $dists = $db->fetch_used_modules_of('DistA-0.01');
      eq_or_diff [sort {$a->{module_dist} cmp $b->{module_dist}} @$dists] => [
        {
          module => 'ModuleA',
          module_dist => 'DistA',
          in_code => 1,
          in_tests => 1,
        },
        {
          module => 'ModuleB',
          module_dist => 'DistA',
          in_code => 1,
          in_tests => 0,
        },
        {
          module => 'Test::ModuleC',
          module_dist => 'TestDistC',
          in_code => 0,
          in_tests => 2,
        },
      ], "correct dists of DistA-0.01";
    }
  }

  $db->remove;
}

{
  my $db = WWW::CPANTS::DB::UsedModules->new(explain => 1);
  $db->setup;

  {
    my $count = $db->fetch_1('select count(*) from used_modules');
    is $count => 0, "num of rows is correct";
  }

  for (0..2000) {
    $db->bulk_insert({
      distv => "Dist$_",
      module => "ModuleA",
    });
  }
  $db->finalize_bulk_insert;

  {
    my $count = $db->fetch_1('select count(*) from used_modules');
    is $count => 2001, "num of rows is correct: $count";
  }

  $db->remove;
}

done_testing;
