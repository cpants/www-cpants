use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB::Queue;
use WWW::CPANTS::Process::Queue;

my $mirror = setup_mirror(qw{
  MARSCHAP/perl-ldap-0.44.tar.gz
});

my $process = WWW::CPANTS::Process::Queue->new;
eval { $process->enqueue_cpan(cpan => $mirror->root) };
ok !$@, "processed a CPAN mirror";
note $@ if $@;

my $queue = WWW::CPANTS::DB::Queue->new;
my $id = $queue->get_first_id;
ok $id, "first id in the queue";
my $path = $queue->get_path($id);
ok $path =~ /perl\-ldap/, "path: $path";

done_testing;
