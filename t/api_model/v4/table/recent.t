use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use WWW::CPANTS::Util::Datetime;
use Test::More;
use Test::Deep qw(cmp_deeply);
use Test::MockTime::HiRes;

fixture {
    my @files = (
        'BAYASHI/App-jl-0.12.tar.gz',
        'ISHIGAKI/JSON-4.02.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    load_task('Traverse')->run(qw/BAYASHI ISHIGAKI/);
    load_task('Analyze')->run(@files);
};

my $model = api_model('V4::Table::Recent');

subtest 'some of mine' => sub {
    my $epoch = epoch_from_date('2019-04-30');
    mock_time {
        my $res = $model->load;
        cmp_deeply $res => {
            'data' => [{
                    'date'     => '2019-06-23',
                    'name'     => 'App-jl',
                    'pause_id' => 'BAYASHI',
                    'score'    => '100',
                    'version'  => '0.12'
                }, {
                    'date'     => '2019-02-23',
                    'name'     => 'JSON',
                    'pause_id' => 'ISHIGAKI',
                    'score'    => '100',
                    'version'  => '4.02'
                },
            ],
            'recordsTotal' => 2,
        };
    }
    $epoch;
};

done_testing;
