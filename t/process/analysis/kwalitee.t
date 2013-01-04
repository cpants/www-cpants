use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Process::Analysis::Kwalitee;

my @data = (
  {
    id => 1,
    dist => 'DistA',
    vname => 'DistA-0.01',
    author => 'AuthorA',
    released_epoch => epoch('2013-01-01'),
    kwalitee => {
      extractable => 1,
    },
  },
  {
    id => 2,
    dist => 'DistB',
    vname => 'DistB-0.01',
    author => 'AuthorB',
    released_epoch => epoch('2013-01-01'),
    kwalitee => {
      extractable => 1,
    },
  },
);

for (0..1) {
  my $process = WWW::CPANTS::Process::Analysis::Kwalitee->new;

  my $db = $process->{db};

  $process->update($_) for @data;
  $process->finalize;

  my $count = $db->fetch_1('select count(*) from kwalitee');

  is $count => @data, "count is correct";
}

done_testing;
