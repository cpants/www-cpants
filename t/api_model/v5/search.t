use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Differences;

fixture {
    my @files = (
        'HEIKO/IsUTF8-0.2.tar.gz',
        'ISHIGAKI/Path-Extended-0.19.tar.gz',
        'ISAAC/DBIx-Objects-0.04.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    load_task('Traverse')->run(qw/HEIKO ISHIGAKI ISAAC/);
};

my $model = api_model('V5::Search');

subtest 'matches both' => sub {
    my $res = $model->load({ name => 'Is' });
    eq_or_diff $res => {
        'authors' => [
            'ISAAC',
            'ISHIGAKI'
        ],
        'dists' => ['IsUTF8'],
    };
};

done_testing;
