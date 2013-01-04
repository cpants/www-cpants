use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Process::Analysis::PrereqModules;

my @data = (
  {
    dist => 'DistA',
    vname => 'DistA-0.01',
    author => 'AuthorA',
    prereq => [
      { requires => 'PrereqA', version => '0', is_prereq => 1 },
      { requires => 'PrereqB', version => '0', is_build_prereq => 1 },
    ],
  },
  {
    dist => 'DistB',
    vname => 'DistB-0.01',
    author => 'AuthorB',
    prereq => [
      { requires => 'PrereqC', version => '0', is_prereq => 1 },
      { requires => 'PrereqD', version => '0', is_build_prereq => 1 },
    ],
  },
  {
    dist => 'DistC',
    vname => 'DistC-0.01',
    author => 'AuthorC',
    prereq => [],
  },
);

my $num_of_prereqs = 0;
for (@data) {
  $num_of_prereqs += @{ $_->{prereq} || [] };
}

for (0..1) {
  my $process = WWW::CPANTS::Process::Analysis::PrereqModules->new;

  my $db = $process->{db};

  $process->update($_) for @data;
  $process->finalize;

  my $count = $db->fetch_1('select count(*) from prereq_modules');

  is $count => $num_of_prereqs, "count is correct";
}

done_testing;
