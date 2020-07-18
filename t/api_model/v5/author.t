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
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
    load_task('PostProcess::UpdateAuthorStats')->run;
    load_task('PostProcess::UpdateRanking')->run;
};

my $model = api_model('V5::Author');

subtest 'me' => sub {
    my $res = $model->load({ pause_id => 'ISHIGAKI' });
    eq_or_diff $res => {
        'ascii_name'            => 'Kenichi Ishigaki',
        'average_core_kwalitee' => '100',
        'average_kwalitee'      => '153.12',
        'cpan_dists'            => 1,
        'deleted'               => 0,
        'email'                 => 'ishigaki@cpan.org',
        'has_perl6'             => 0,
        'homepage'              => 'http://d.hatena.ne.jp/charsbar',
        'joined_on'             => '2005-12-17',
        'last_new_release_on'   => '2011-05-31',
        'last_release_on'       => '2011-05-31',
        'name'                  => 'Kenichi Ishigaki',
        'nologin'               => 0,
        'pause_id'              => 'ISHIGAKI',
        'rank'                  => 1,
        'recent_dists'          => 0,
        'system'                => 0,
        'year'                  => 2005,
    };
};

done_testing;
