use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Differences;

fixture {
    my @files = (
        'ISHIGAKI/Path-Extended-0.19.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    $testpan->cpan->update_indices;

    load_task('UpdateCPANIndices::Whois')->run;
    load_task('Traverse')->run;
    load_task('Analyze')->run(@files);
    load_task('PostProcess::UpdateAuthorStats')->run;
    load_task('PostProcess::UpdateRanking')->run;
};

my $model = api_model('V4::Table::Ranking');

subtest 'some of mine' => sub {
    my $res = $model->load({ league => 'less_than_five' });
    eq_or_diff $res => {
        'data' => [{
            'average_core_kwalitee' => 100,
            'average_kwalitee'      => '153.12',
            'cpan_dists'            => 1,
            'has_perl6'             => 0,
            'json'                  => undef,
            'json_updated_at'       => undef,
            'last_new_release_at'   => '1306782406',
            'last_release_at'       => '1306782406',
            'pause_id'              => 'ISHIGAKI',
            'rank'                  => 1,
            'recent_dists'          => 0,
        }],
        'recordsTotal' => 1,
    };
};

done_testing;
