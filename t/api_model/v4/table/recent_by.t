use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use WWW::CPANTS::Util::Datetime;
use Test::More;
use Test::Differences;
use Test::MockTime::HiRes;

fixture {
    my @files = (
        'ISHIGAKI/JSON-4.02.tar.gz',
        'ISHIGAKI/Path-Extended-0.19.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
};

my $model = api_model('V4::Table::RecentBy');

subtest 'some of mine' => sub {
    my $epoch = epoch_from_date('2019-04-30');
    mock_time {
        my $res = $model->load({ pause_id => 'ISHIGAKI' });
        eq_or_diff $res => {
            'data' => [{
                    'date'    => '2019-02-23',
                    'fails'   => [],
                    'name'    => 'JSON',
                    'score'   => '100',
                    'version' => '4.02'
                },
            ],
            'recordsTotal' => 1,
        };
    }
    $epoch;
};

done_testing;
