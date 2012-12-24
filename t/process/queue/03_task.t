use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB::Queue;
use WWW::CPANTS::Process::Queue;

{
  my $mirror = setup_mirror(qw{
    MIYAGAWA/Task-Plack-0.26.tar.gz
  });

  my $process = WWW::CPANTS::Process::Queue->new;
  eval { $process->enqueue_cpan(cpan => $mirror->root) };
  ok !$@, "processed a CPAN mirror";
  note $@ if $@;

  my $queue = WWW::CPANTS::DB::Queue->new;
  my $id = $queue->fetch_first_id;
  ok $id, "first id in the queue";
  my $path = $queue->fetch_path($id);
  ok $path =~ /Task\-Plack/, "path: $path";
}

done_testing;
