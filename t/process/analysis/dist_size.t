use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Process::Analysis::DistSize;

my @data = (
  {
    id => 1,
    size_packed => 100,
    size_unpacked => 100,
    files => 3,
  },
  {
    id => 2,
    size_packed => 150,
    size_unpacked => 150,
    files => 3,
  },
);

for (0..1) {
  my $process = WWW::CPANTS::Process::Analysis::DistSize->new;

  my $db = $process->{db};

  $process->update($_) for @data;
  $process->finalize;

  my $count = $db->fetch_1('select count(*) from dist_size');

  is $count => @data, "count is correct";
}

done_testing;
