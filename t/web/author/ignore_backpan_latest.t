use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Mojo;

fixture {
    my @files = (
        'ISHIGAKI/JSON-4.02.tar.gz',
        'ISHIGAKI/JSON-4.00.tar.gz',
        'ISHIGAKI/Parse-PMFile-0.42.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    $testpan->cpan->update_indices;

    $testpan->backpan->add_files(
        'ISHIGAKI/Pod-Perldocs-0.17.tar.gz',  ## backpan latest with kwalitee issues
    );

    load_task('UpdateCPANIndices')->run;
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
    load_task('PostProcess')->run;
};

subtest 'get json' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');
    $t->get_ok('/author/ishigaki.json')->status_is(200);
    my $json = $t->tx->res->json;
    is $json->{author}{average_core_kwalitee} => 100, "Pod::Perldocs is ignored";
};

done_testing;
