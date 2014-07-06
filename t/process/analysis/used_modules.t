use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Process::Analysis::UsedModules;

my @data = (
  {
    dist => 'DistA',
    vname => 'DistA-0.01',
    uses => {
      used_in_code => {
        'ModuleA' => 1,
      },
      used_in_tests => {
        'ModuleB' => 1,
      },
    },
  },
  {
    dist => 'DistB',
    vname => 'DistB-0.01',
    uses => {
      used_in_code => {
        'ModuleC' => 1,
      },
      used_in_tests => {
        'ModuleD' => 1,
      },
    },
  },
  {
    dist => 'DistC',
    vname => 'DistC-0.01',
    uses => {},
  },
);

my $num_of_modules = 0;
for (@data) {
  $num_of_modules += keys %{ $_->{uses} || {} };
}

for (0..1) {
  my $process = WWW::CPANTS::Process::Analysis::UsedModules->new;

  my $db = $process->{db};

  $process->update($_) for @data;
  $process->finalize;

  my $count = $db->fetch_1('select count(*) from used_modules');

  is $count => $num_of_modules, "count is correct";
}

done_testing;
