use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB::Queue;
use WWW::CPANTS::Process::Queue;

my $mirror = setup_mirror();

# failing tests: bad options
{
  WWW::CPANTS::DB::Queue->new->dbfile->remove;
  my $process = WWW::CPANTS::Process::Queue->new;
  eval { $process->enqueue_cpan() };
  ok $@ && $@ =~ /requires a CPAN mirror/;
}

{
  WWW::CPANTS::DB::Queue->new->dbfile->remove;
  my $process = WWW::CPANTS::Process::Queue->new;
  eval { $process->enqueue_cpan(cpan => '.') };
  ok $@ && $@ =~ /not a CPAN mirror/;
}

# process only a small part of CPAN
{
  for my $workers (0, 2) {
    WWW::CPANTS::DB::Queue->new->dbfile->remove;
    my $process = WWW::CPANTS::Process::Queue->new;
    eval { $process->enqueue_cpan(cpan => $mirror->root, workers => $workers) };
    ok !$@, "processed a CPAN mirror";
    note $@ if $@;

    my $queue = WWW::CPANTS::DB::Queue->new;
    my $id = $queue->fetch_first_id;
    ok $id, "first id in the queue";
    my $path = $queue->fetch_path($id);
    ok $path, "path: $path";

    $id = $queue->mark;
    ok $id, "$id is marked";
    ok !$queue->fetch_first_id, "no ids are left in the queue";
    $queue->mark_done($id);
  }
}

done_testing;
