use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Process::Analysis::Errors;

my @data = (
  {
    id => 1,
    vname => 'DistA-0.01',
    error => {
      scalar => 'ScalarError',
      array  => [qw/error1 error2/],
    },
  },
  {
    id => 2,
    vname => 'DistA-0.02',
    error => {
      scalar => 'ScalarError2',
      array  => [qw/error3 error4/],
    },
  },
);

for (0..1) {
  my $process = WWW::CPANTS::Process::Analysis::Errors->new;

  my $db = $process->{db};

  $process->update($_) for @data;
  $process->finalize;

  my $count = $db->fetch_1('select count(*) from errors');

  is $count => @data * 2, "count is correct";
}

done_testing;
