use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;

{
  my $db = db('Packages', explain => 1);

  for (0..1) { # repetition doesn't break things?
    $db->set_test_data(
      cols => [qw/module version file dist distv author status/],
      rows => [
        [qw(ModuleA 0.01 lib/Foo/ModuleA.pm DistA DistA-0.01 Author 0)],
      ],
    );

    no_scan_table {
      my $dist = $db->fetch_dist_by_module('ModuleA');
      eq_or_diff $dist => [{
        module => 'ModuleA',
        version => '0.01',
        file => 'lib/Foo/ModuleA.pm',
        dist => 'DistA',
        distv => 'DistA-0.01',
        author => 'Author',
        status => 0,
      }], "got a dist"
    };
  }

  $db->remove;
}

done_testing;