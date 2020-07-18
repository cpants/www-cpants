use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Mojo;

fixture {
    my @files = (
        'ISHIGAKI/JSON-4.02.tar.gz',
        'ISHIGAKI/Path-Extended-0.19.tar.gz',
        'ISHIGAKI/Pod-Perldocs-0.17.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    $testpan->cpan->update_indices;

    load_task('UpdateCPANIndices')->run;
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
    load_task('PostProcess')->run;
};

subtest 'get' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');
    $t->get_ok('/author/ishigaki')->status_is(200);
};

subtest 'get json' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');
    $t->get_ok('/author/ishigaki.json')->status_is(200);
};

subtest 'get png' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');
    $t->get_ok('/author/ishigaki.png')->status_is(200);
};

subtest 'get svg' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');
    $t->get_ok('/author/ishigaki.svg')->status_is(200);
};

subtest 'feed' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');
    $t->get_ok('/author/ishigaki/feed')->status_is(200);
};

done_testing;
