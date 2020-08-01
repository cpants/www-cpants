use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Mojo;

fixture {
    my @files = (
        'RRA/podlators-4.14.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    $testpan->cpan->update_indices;

    load_task('UpdateCPANIndices')->run;
    load_task('Traverse')->run(qw/RRA/);
    load_task('Analyze')->run(@files);
    load_task('PostProcess')->run;
};

my @paths = qw(
    /dist/podlators
    /release/RRA/podlators-4.14
);

subtest 'no E<>' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    for my $path (@paths) {
        $t->get_ok($path)->status_is(200);
        $t->text_is('h2' => 'podlators 4.14');
        my $tbody = $t->tx->res->dom->at('#modules tbody');
        for my $tr ($tbody->find('tr')->each) {
            for my $td ($tr->find('td')->each) {
                unlike $td->text => qr/E<[^>]+>/, $td->text;
            }
        }
    }
};

done_testing;
