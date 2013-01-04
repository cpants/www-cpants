use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Process::Analysis::ModuleSignature;

my @data = (
  {
    id => 1,
    valid_signature => 0,
    released_epoch => epoch('2013-01-01'),
  },
  {
    id => 2,
    valid_signature => -1,
    released_epoch => epoch('2013-01-01'),
  },
);

for (0..1) {
  my $process = WWW::CPANTS::Process::Analysis::ModuleSignature->new;

  my $db = $process->{db};

  $process->update($_) for @data;
  $process->finalize;

  my $count = $db->fetch_1('select count(*) from module_signature');

  is $count => @data, "count is correct";
}

done_testing;
