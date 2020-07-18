use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Differences;

fixture {
    my @files = (
        'ISHIGAKI/JSON-4.02.tar.gz',
        'MAKAMAKA/JSON-2.90.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    load_task('Traverse')->run(qw/ISHIGAKI MAKAMAKA/);
    load_task('Analyze')->run(@files);
};

my $model = api_model('V5::Dist::Common');

my @params = (
    [dist    => { name => 'JSON' }],
    [release => { name => 'JSON-4.02', pause_id => 'ISHIGAKI' }],
);

for my $param (@params) {
    my ($name, $load_arg) = @$param;
    my $subtest = sub ($load_arg) {
        return sub {
            my $res = $model->load($load_arg);
            eq_or_diff $res => {
                'advisories'        => undef,
                'author'            => 'ISHIGAKI',
                'bugtracker_url'    => 'https://github.com/makamaka/JSON/issues',
                'core_kwalitee'     => '100',
                'cpan'              => 1,
                'first'             => 0,
                'first_release_at'  => 1383215955,
                'first_uid'         => '8620859132569613113',
                'github'            => undef,
                'id'                => 1,
                'kwalitee'          => '153.12',
                'last_release_at'   => 1550888787,
                'last_release_by'   => 'ISHIGAKI',
                'latest'            => 1,
                'latest_dev_uid'    => undef,
                'latest_stable_uid' => '10167401650567662953',
                'latest_uid'        => '10167401650567662953',
                'name'              => 'JSON',
                'name_version'      => 'JSON-4.02',
                'path'              => 'I/IS/ISHIGAKI/JSON-4.02.tar.gz',
                'recent_releases'   => [{
                        'author'         => 'ISHIGAKI',
                        'cpan'           => 1,
                        'released'       => 1550888787,
                        'stable'         => 1,
                        'uid'            => '10167401650567662953',
                        'version'        => '4.02',
                        'version_number' => undef,
                    },
                    {
                        'author'         => 'MAKAMAKA',
                        'cpan'           => 1,
                        'released'       => 1383215955,
                        'stable'         => 1,
                        'uid'            => '8620859132569613113',
                        'version'        => '2.90',
                        'version_number' => undef,
                    },
                ],
                'released'       => 1550888787,
                'repository_url' => 'https://github.com/makamaka/JSON',
                'resources'      => {
                    'bugtracker' => 'https://github.com/makamaka/JSON/issues',
                    'repository' => 'https://github.com/makamaka/JSON',
                },
                'rt'             => undef,
                'size'           => undef,
                'stable'         => 1,
                'uid'            => '10167401650567662953',
                'uids'           => '[{"author":"ISHIGAKI","cpan":1,"released":1550888787,"stable":1,"uid":10167401650567662953,"version":"4.02","version_number":null},{"author":"MAKAMAKA","cpan":1,"released":1383215955,"stable":1,"uid":8620859132569613113,"version":"2.90","version_number":null}]',
                'used_by'        => undef,
                'version'        => '4.02',
                'version_number' => '4.02',
                'year'           => 2019,
            };
        };
    };
    subtest $name => $subtest->($load_arg);
}

done_testing;
