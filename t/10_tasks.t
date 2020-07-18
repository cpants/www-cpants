use Mojo::Base -strict, -signatures;
use FindBin;
use Test::More;
use WWW::CPANTS::Test::TestPAN;
use WWW::CPANTS::Bin::Runner;
use Syntax::Keyword::Try;

my $testpan = WWW::CPANTS::Test::TestPAN->new->setup;

my $runner = WWW::CPANTS::Bin::Runner->new;

for my $name ($runner->ctx->task_names->@*) {
    try {
        local @ARGV;
        ok $runner->run_tasks($name), $name;
    } catch {
        fail "$name: $@"
    }
}

done_testing;
