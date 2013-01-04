use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Process::Analysis::ModuleInstall;

my @data = (
  {
    id => 1,
    module_install_version => '1.00',
    released_epoch => epoch('2013-01-01'),
  },
  {
    id => 2,
    module_install_version => '1.05',
    released_epoch => epoch('2013-01-01'),
  },
  {
    id => 3,
    released_epoch => epoch('2013-01-01'),
  },
);

for (0..1) {
  my $process = WWW::CPANTS::Process::Analysis::ModuleInstall->new;

  my $db = $process->{db};

  $process->update($_) for @data;
  $process->finalize;

  my $count = $db->fetch_1('select count(*) from module_install');

  is $count => @data - 1, "count is correct";
}

done_testing;
