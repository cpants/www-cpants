use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB::Queue;
use WWW::CPANTS::Process::Queue;

{ # Bundle::Everything should be ignored as it pollutes "is_prereq"
  my $mirror = setup_mirror(qw{
    RSPIER/Bundle-Everything-0.06.tar.gz
  });

  my $process = WWW::CPANTS::Process::Queue->new;
  eval { $process->enqueue_cpan(cpan => $mirror->root) };
  ok !$@, "processed a CPAN mirror";
  note $@ if $@;

  my $queue = WWW::CPANTS::DB::Queue->new;
  my $id = $queue->fetch_first_id;
  ok !$id, "Bundle::Everything should be ignored";
}

{ # Other Bundles should be ok
  my $mirror = setup_mirror(qw{
    ANDK/Bundle-CPAN-1.861.tar.gz
  });

  my $process = WWW::CPANTS::Process::Queue->new;
  eval { $process->enqueue_cpan(cpan => $mirror->root) };
  ok !$@, "processed a CPAN mirror";
  note $@ if $@;

  my $queue = WWW::CPANTS::DB::Queue->new;
  my $id = $queue->fetch_first_id;
  ok $id, "first id in the queue";
  my $path = $queue->fetch_path($id);
  ok $path =~ /Bundle\-CPAN/, "path: $path";
}

done_testing;
