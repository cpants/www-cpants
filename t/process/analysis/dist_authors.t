use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Process::Analysis::DistAuthors;

my @data = (
  {
    dist => 'DistA',
    author => 'AuthorA',
  },
  {
    dist => 'DistB',
    author => 'AuthorB',
  },
);

for (0..1) {
  my $process = WWW::CPANTS::Process::Analysis::DistAuthors->new;

  my $db = $process->{db};

  $process->update($_) for @data;
  $process->finalize;

  my $count = $db->fetch_1('select count(*) from dist_authors');

  is $count => @data, "count is correct";
}

done_testing;
