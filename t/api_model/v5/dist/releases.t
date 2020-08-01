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

my $model = api_model('V5::Dist::Releases');

my @params = (
    [dist    => { name => 'Test-CPANfile' }],
    [release => { name => 'Test-CPANfile-0.06', pause_id => 'ISHIGAKI' }],
);

for my $param (@params) {
SKIP: {
        my ($name, $load_arg) = @$param;
        skip "$name is not supported yet", 1 if $name ne 'dist';    ## FIXME!
        my $subtest = sub ($load_arg) {
            return sub {
                my $res = $model->load($load_arg);
                note explain $res;
                cmp_deeply $res => {
                    'data' => [{
                        'author'       => 'ISHIGAKI',
                        'availability' => 'CPAN',
                        'date'         => '2019-01-16',
                        'name'         => 'Test-CPANfile',
                        'score'        => '100',
                        'version'      => '0.06'
                    }],
                    'recordsTotal' => 1
                };
            };
        };
        subtest $name => $subtest->($load_arg);
    }
}

done_testing;
