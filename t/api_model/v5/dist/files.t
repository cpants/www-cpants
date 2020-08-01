use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Deep qw(cmp_deeply);

fixture {
    my @files = (
        'ISHIGAKI/Test-CPANfile-0.06.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
};

my $model = api_model('V5::Dist::Files');

my @params = (
    [dist    => { name => 'Test-CPANfile' }],
    [release => { name => 'Test-CPANfile-0.06', pause_id => 'ISHIGAKI' }],
);

for my $param (@params) {
    my ($name, $load_arg) = @$param;
    my $subtest = sub ($load_arg) {
        return sub {
            my $res = $model->load($load_arg);
            cmp_deeply $res => {
                'data' => {
                    'files' => {
                        'Changes' => {
                            'mtime' => 1547585305,
                            'size'  => 336
                        },
                        'LICENSE' => {
                            'mtime' => 1511599309,
                            'size'  => 18590
                        },
                        'MANIFEST' => {
                            'mtime' => 1547586141,
                            'size'  => 319
                        },
                        'META.json' => {
                            'mtime' => 1547586141,
                            'size'  => 1638
                        },
                        'META.yml' => {
                            'mtime' => 1547586141,
                            'size'  => 892
                        },
                        'Makefile.PL' => {
                            'mtime'    => 1544019785,
                            'requires' => {
                                'ExtUtils::MakeMaker::CPANfile' => '0',
                                'strict'                        => '0',
                                'warnings'                      => '0'
                            },
                            'size' => 509
                        },
                        'README' => {
                            'mtime' => 1511599309,
                            'size'  => 398
                        },
                        'cpanfile' => {
                            'mtime' => 1544028549,
                            'size'  => 461
                        },
                        'lib/Test/CPANfile.pm' => {
                            'license'  => 'Perl_5',
                            'module'   => 'Test::CPANfile',
                            'mtime'    => 1547585313,
                            'requires' => {
                                'Exporter'                               => '5.57',
                                'Module::CPANfile'                       => '0',
                                'Perl::PrereqScanner::NotQuiteLite::App' => '0',
                                'Test::More'                             => '0',
                                'strict'                                 => '0',
                                'warnings'                               => '0'
                            },
                            'size' => 6770
                        },
                        't/00_load.t' => {
                            'mtime'    => 1511599309,
                            'no_index' => 1,
                            'requires' => {
                                'Test::UseAllModules' => '0',
                                'strict'              => '0',
                                'warnings'            => '0'
                            },
                            'size' => 77
                        },
                        't/10_self.t' => {
                            'mtime'    => 1538285441,
                            'no_index' => 1,
                            'requires' => {
                                'CPAN::Common::Index::MetaDB' => '0',
                                'Test::CPANfile'              => '0',
                                'Test::More'                  => '0.88',
                                'strict'                      => '0',
                                'warnings'                    => '0'
                            },
                            'size' => 226
                        },
                        'xt/99_pod.t' => {
                            'mtime' => 1511599309,
                            'size'  => 229
                        },
                        'xt/99_podcoverage.t' => {
                            'mtime' => 1511599309,
                            'size'  => 253
                        },
                    },
                },
            };
        };
    };
    subtest $name => $subtest->($load_arg);
}

done_testing;
