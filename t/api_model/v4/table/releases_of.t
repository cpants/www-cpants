use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Deep qw(cmp_deeply);

fixture {
    my @files = (
        'ISHIGAKI/JSON-4.02.tar.gz',
        'MAKAMAKA/JSON-2.90.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    load_task('Traverse')->run(qw/ISHIGAKI MAKAMAKA/);
    load_task('Analyze')->run(@files);
};

my $model = api_model('V4::Table::ReleasesOf');

subtest 'some of mine' => sub {
    my $res = $model->load({ name => 'JSON' });
    cmp_deeply $res => {
        'data' => [{
                'author'       => 'ISHIGAKI',
                'availability' => 'CPAN',
                'date'         => '2019-02-23',
                'name'         => 'JSON',
                'score'        => '100',
                'version'      => '4.02'
            },
            {
                'author'       => 'MAKAMAKA',
                'availability' => 'CPAN',
                'date'         => '2013-10-31',
                'name'         => 'JSON',
                'score'        => '100',
                'version'      => '2.90'
            }

        ],
        'recordsTotal' => 2,
    };
};

done_testing;
