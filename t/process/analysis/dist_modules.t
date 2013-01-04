use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Process::Analysis::DistModules;

my @data = (
  {
    dist => 'DistA',
    vname => 'DistA-0.01',
    modules => [
      {
        module => 'ModuleA',
        file => 'lib/ModuleA.pm',
      },
      {
        module => 'ModuleB',
        file => 'lib/ModuleB.pm',
      },
    ],
    released_epoch => epoch('2013-01-01'),
  },
  {
    dist => 'DistB',
    vname => 'DistB-0.01',
    modules => [
      {
        module => 'ModuleC',
        file => 'lib/ModuleC.pm',
      },
      {
        module => 'ModuleD',
        file => 'lib/ModuleD.pm',
      },
    ],
    released_epoch => epoch('2013-01-01'),
  },
  {
    dist => 'DistC',
    vname => 'DistC-0.01',
    modules => [],
    released_epoch => epoch('2013-01-01'),
  },
);

my $num_of_modules;
for (@data) {
  $num_of_modules += @{$_->{modules} || []};
}

for (0..1) {
  my $process = WWW::CPANTS::Process::Analysis::DistModules->new;

  my $db = $process->{db};

  $process->update($_) for @data;
  $process->finalize;

  my $count = $db->fetch_1('select count(*) from dist_modules');

  is $count => $num_of_modules, "count is correct";
}

done_testing;
