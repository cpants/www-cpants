use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Deep qw(cmp_deeply);

my $model = api_model('V5::Status');

subtest 'status' => sub {
    my $testpan = setup_testpan;
    load_task('AnalyzeAll')->run;

    my $res = $model->load({});
    ok $res->{last_analyzed};
    ok !$res->{maintenance};
};

done_testing;
