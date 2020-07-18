use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Deep qw/cmp_deeply re/;

fixture {
    my @files = (
        'ISHIGAKI/Test-CPANfile-0.06.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    $testpan->cpan->update_indices;

    load_task('UpdateCPANIndices::PackagesDetails')->run;
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
    load_task('PostProcess::UpdateReverseDependency')->run(@files);
};

my $model = api_model('V5::Dist::Prereq');

my @params = (
    [dist    => { name => 'Test-CPANfile' }],
    [release => { name => 'Test-CPANfile-0.06', pause_id => 'ISHIGAKI' }],
);

sub _re ($name) { $name =~ s/[0-9.]+$//; re('^' . $name . '[0-9.]+$') }

for my $param (@params) {
    my ($name, $load_arg) = @$param;
    my $subtest = sub ($load_arg) {
        return sub {
            my $res = $model->load($load_arg);
            cmp_deeply $res => {
                'data' => {
                    'build_requires' => [{
                            'latest_dist'       => _re('CPAN-Common-Index-0.010'),
                            'latest_maintainer' => 'DAGOLDEN',
                            'latest_version'    => _re('0.010'),
                            'name'              => 'CPAN::Common::Index',
                            'version'           => '0'
                        },
                        {
                            'core_since'        => '5',
                            'latest_dist'       => _re('ExtUtils-MakeMaker-7.36'),
                            'latest_maintainer' => 'BINGOS',
                            'latest_version'    => _re('7.36'),
                            'name'              => 'ExtUtils::MakeMaker',
                            'version'           => '0'
                        },
                        {
                            'core_since'        => '5.010001',
                            'latest_dist'       => _re('Test-Simple-1.302164'),
                            'latest_maintainer' => 'EXODIST',
                            'latest_version'    => _re('1.302164'),
                            'name'              => 'Test::More',
                            'version'           => '0.88'
                        },
                        {
                            'latest_dist'       => _re('Test-UseAllModules-0.17'),
                            'latest_maintainer' => 'ISHIGAKI',
                            'latest_version'    => _re('0.17'),
                            'name'              => 'Test::UseAllModules',
                            'version'           => '0.17'
                        }
                    ],
                    'configure_requires' => [{
                        'latest_dist'       => _re('ExtUtils-MakeMaker-CPANfile-0.09'),
                        'latest_maintainer' => 'ISHIGAKI',
                        'latest_version'    => _re('0.09'),
                        'name'              => 'ExtUtils::MakeMaker::CPANfile',
                        'version'           => '0.08'
                    }],
                    'runtime_requires' => [{
                            'core_since'        => '5.008003',
                            'latest_dist'       => _re('Exporter-5.73'),
                            'latest_maintainer' => 'TODDR',
                            'latest_version'    => _re('5.73'),
                            'name'              => 'Exporter',
                            'version'           => '5.57'
                        },
                        {
                            'latest_dist'       => _re('Module-CPANfile-1.1004'),
                            'latest_maintainer' => 'MIYAGAWA',
                            'latest_version'    => _re('1.1004'),
                            'name'              => 'Module::CPANfile',
                            'version'           => '0'
                        },
                        {
                            'core_since'        => '5.018002',
                            'latest_dist'       => _re('Module-CoreList-5.20190620'),
                            'latest_maintainer' => 'BINGOS',
                            'latest_version'    => _re('5.20190620'),
                            'name'              => 'Module::CoreList',
                            'version'           => '2.99'
                        },
                        {
                            'latest_dist'       => _re('Perl-PrereqScanner-NotQuiteLite-0.9906'),
                            'latest_maintainer' => 'ISHIGAKI',
                            'latest_version'    => _re('0.9906'),
                            'name'              => 'Perl::PrereqScanner::NotQuiteLite',
                            'version'           => '0.9902'
                        },
                    ],
                },
            };
        };
    };
    subtest $name => $subtest->($load_arg);
}

done_testing;
