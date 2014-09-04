use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;

{
  my $db = db('UsedModules', explain => 1);

  for (0..1) { # repetition doesn't break things?
    $db->set_test_data(
      cols => [qw/distv module used_in_code used_in_tests/],
      rows => [
        [qw/DistA-0.01 ModuleA 1 1/],
        [qw/DistA-0.01 ModuleB 1 0/],
        [qw/DistA-0.01 Test::ModuleC 0 2/],
        [qw/DistB-0.01 ModuleA 1 1/],
        [qw/DistB-0.01 ModuleD 1 0/],
        [qw/DistB-0.01 Test::ModuleC 0 2/],
        [qw/DistB-0.01 Test::ModuleE 0 2/],
      ],
    );

    no_scan_table {
      my $modules = $db->fetch_all_used_modules;
      eq_or_diff [sort map {$_->{module}} @$modules] => [qw/ModuleA ModuleB ModuleD Test::ModuleC Test::ModuleE/], "correct modules";
    } "known slow query";

    no_scan_table {
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
      $db->finalize_update_used_module_dist;
      my $dists = $db->fetchall_1('select distinct(module_dist) from used_modules');
      eq_or_diff [sort @$dists] => [qw/DistA DistD TestDistC TestDistE/], "correct used dists";
    };

    no_scan_table {
      my %empty =
        map {$_ => 0}
        map {($_.'_in_code', $_.'_in_tests', $_.'_in_config')}
        map {($_, $_.'_in_eval')}
        qw/used required noed/;
      my %dist_info = (
          dist => undef,
          distv => 'DistA-0.01',
          included => undef,
      );

      my $dists = $db->fetch_used_modules_of('DistA-0.01');
      eq_or_diff [sort {$a->{module_dist} cmp $b->{module_dist}} @$dists] => [
        {
          %dist_info,
          module => 'ModuleA',
          module_dist => 'DistA',
          %empty,
          used_in_code => 1,
          used_in_tests => 1,
        },
        {
          %dist_info,
          module => 'ModuleB',
          module_dist => 'DistA',
          %empty,
          used_in_code => 1,
        },
        {
          %dist_info,
          module => 'Test::ModuleC',
          module_dist => 'TestDistC',
          %empty,
          used_in_tests => 2,
        },
      ], "correct dists of DistA-0.01";
    };
  }

  $db->remove;
}

done_testing;
