use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Deep qw(cmp_deeply);

fixture {
    my @files = (
        'ISHIGAKI/Path-Extended-0.19.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
};

my $model = api_model('V1::Uploads');

subtest 'mine' => sub {
    my $res = $model->load({d => 'Path-Extended'});

    cmp_deeply $res => [
        {
            author => 'ISHIGAKI',
            filename => 'Path-Extended-0.19.tar.gz'
        },
    ];
};

done_testing;
