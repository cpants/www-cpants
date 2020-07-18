use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Differences;

fixture {
    my @files = (
        'ISHIGAKI/Pod-Perldocs-0.17.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
    load_task('PostProcess::UpdateCaches')->run;
};

my $model = api_model('V5::Kwalitee::Indicator');

subtest 'some' => sub {
    my $res = $model->load({ name => 'main_module_version_matches_dist_version' });
    eq_or_diff $res => {
        'data' => {
            'failing_latest_releases' => [{
                    'author'       => 'ISHIGAKI',
                    'availability' => 'Latest',
                    'date'         => '2011-01-06',
                    'name_version' => 'Pod-Perldocs-0.17'
                },
            ],
            'indicator' => {
                'defined_in'  => 'Module::CPANTS::SiteKwalitee::Version',
                'description' => "The version and/or name of the main module in this distribution doesn't match the distribution version and/or name.",
                'level'       => 'core',
                'name'        => 'main_module_version_matches_dist_version',
                'remedy'      => 'Make sure that the main module name and version are the same of the distribution.'
            },
            'stats' => [{
                    'backpan_fails'   => 1,
                    'backpan_uploads' => 1,
                    'cpan_fails'      => 1,
                    'cpan_uploads'    => 1,
                    'latest_fails'    => 1,
                    'latest_uploads'  => 1,
                    'year'            => 2011
                },
            ],
        },
        'total_failing_latest_releases' => 1
    };
};

done_testing;
