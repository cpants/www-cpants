use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Differences;

fixture {
    my @files = (
        'ISHIGAKI/Pod-PerldocJp-0.19.tar.gz',
        'TOKUHIROM/LiBot-v0.0.3.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    load_task('Traverse')->run(qw/ISHIGAKI TOKUHIROM/);
    load_task('Analyze')->run(@files);
    load_task('PostProcess::UpdateReverseDependency')->run;
};

my $model = api_model('V4::Table::ReverseDependenciesOf');

subtest 'some of mine' => sub {
    my $res = $model->load({ name => 'Pod-PerldocJp' });
    eq_or_diff $res => {
        'data' => [{
            'author'       => 'TOKUHIROM',
            'date'         => '2013-10-12',
            'name_version' => 'LiBot-v0.0.3',
            'score'        => '96.88'
        }],
        'recordsTotal' => 1,
    };
};

done_testing;
