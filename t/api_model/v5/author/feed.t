use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Differences;

fixture {
    my @files = (
        'ISHIGAKI/Path-Extended-0.19.tar.gz',
        'ISHIGAKI/Pod-Perldocs-0.17.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    load_task('UpdateCPANIndices::Whois')->run;
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
};

my $model = api_model('V5::Author::Feed');

subtest 'mine' => sub {
    my $res = $model->load({ pause_id => 'ISHIGAKI' });
    eq_or_diff $res => {
        'entries' => [{
                'id'      => 'Path-Extended-0.19',
                'link'    => '/release/ISHIGAKI/Path-Extended-0.19',
                'summary' => 'Kwalitee: 100',
                'title'   => 'Path-Extended-0.19',
                'updated' => '2011-05-31T04:06:46Z'
            },
            {
                'id'      => 'Pod-Perldocs-0.17',
                'link'    => '/release/ISHIGAKI/Pod-Perldocs-0.17',
                'summary' => 'Kwalitee: 96.88; Core Fails: main_module_version_matches_dist_version',
                'title'   => 'Pod-Perldocs-0.17',
                'updated' => '2011-01-06T16:12:00Z'
            },
        ],
        'feed' => {
            'author'  => 'CPANTS',
            'title'   => 'CPANTS Feed for ISHIGAKI',
            'updated' => '2011-05-31T04:06:46Z'
        },
    };
};

done_testing;
