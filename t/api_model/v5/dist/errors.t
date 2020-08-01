use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Deep qw(cmp_deeply);

fixture {
    my @files = (
        'ISHIGAKI/Pod-Perldocs-0.17.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
};

my $model = api_model('V5::Dist::Errors');

my @params = (
    [dist    => { name => 'Pod-Perldocs' }],
    [release => { name => 'Pod-Perldocs-0.17', pause_id => 'ISHIGAKI' }],
);

for my $param (@params) {
    my ($name, $load_arg) = @$param;
    my $subtest = sub ($load_arg) {
        return sub {
            my $res = $model->load($load_arg);
            cmp_deeply $res => {
                'data' => {
                    'errors' => [{
                            'category' => 'configure_prereq_matches_use',
                            'error'    => ['Module::Build'],
                        },
                    ],
                },
            };
        };
    };
    subtest $name => $subtest->($load_arg);
}

done_testing;
