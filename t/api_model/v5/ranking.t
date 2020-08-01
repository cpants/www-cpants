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
    $testpan->cpan->update_indices;

    load_task('UpdateCPANIndices::Whois')->run;
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
    load_task('PostProcess::UpdateAuthorStats')->run;
    load_task('PostProcess::UpdateRanking')->run;
};

my $model = api_model('V5::Ranking');

subtest 'less_than_five' => sub {
    my $res = $model->load({ league => 'less_than_five' });
    cmp_deeply $res => {
        'data' => [{
                'average_core_kwalitee' => '100',
                'cpan_dists'            => 1,
                'last_release_on'       => '2011-05-31',
                'pause_id'              => 'ISHIGAKI',
                'rank'                  => 1
            },
        ],
        'recordsTotal' => 1
    };
};

done_testing;
