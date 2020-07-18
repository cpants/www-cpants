use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use WWW::CPANTS::Util::Datetime;
use Test::More;
use Test::Mojo;
use Test::MockTime::HiRes;

fixture {
    my @files = (
        'ISHIGAKI/JSON-4.02.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
};

my $t = Test::Mojo->new('WWW::CPANTS::Web');

subtest 'get' => sub {
    my $epoch = epoch_from_date('2019-12-31');
    mock_time {
        $t->get_ok('/recent')->status_is(200);
    }
    $epoch;
};

done_testing;
