use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use WWW::CPANTS::Util::Datetime;
use Test::More;
use Test::Deep qw(cmp_deeply);
use Test::MockTime::HiRes;

fixture {
    my @files = (
        'ISHIGAKI/JSON-4.02.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    load_task('UpdateCPANIndices::Whois')->run;
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
};

my $model = api_model('V5::Author::RecentReleases');

subtest 'matches both' => sub {
    my $epoch = epoch_from_date('2019-04-30');
    mock_time {
        my $res = $model->load({ pause_id => 'ISHIGAKI' });
        cmp_deeply $res => {
            'data' => [{
                    'date'    => '2019-02-23',
                    'fails'   => [],
                    'name'    => 'JSON',
                    'score'   => '100',
                    'version' => '4.02'
                },
            ],
            'recordsTotal' => 1
        };
    }
    $epoch;
};

done_testing;
