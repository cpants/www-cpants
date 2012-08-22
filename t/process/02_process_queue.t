use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Process::Queue;
use WWW::CPANTS::Process::Analysis;
use WWW::CPANTS::DB::Queue;
use WWW::CPANTS::DB::Analysis;

my $mirror = setup_mirror();

for my $workers (0, 2) {
  next if $workers and $INC{'Devel/Cover.pm'};

  WWW::CPANTS::DB::Queue->new->dbfile->remove;
  WWW::CPANTS::DB::Analysis->new->dbfile->remove;

  {
    my $process = WWW::CPANTS::Process::Queue->new;
    $process->enqueue_cpan(cpan => $mirror->root);
  }

  {
    my $process = WWW::CPANTS::Process::Analysis->new;
    $process->process_queue(cpan => $mirror->root, workers => $workers);

    my $db = WWW::CPANTS::DB::Analysis->new;
    my $row = $db->fetch('select * from analysis where distv = ?', 'Path-Extended-0.19');
    ok $row;
    # note explain $row;
  }
}

done_testing;
