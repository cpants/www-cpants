use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Process::CPAN;
use WWW::CPANTS::DB;

my $worepan = setup_mirror();

my $process = WWW::CPANTS::Process::CPAN->new;
$process->update(cpan => $worepan->root);

my $author = db('Authors')->fetch_author('ISHIGAKI');

ok $author, "got author";

done_testing;
