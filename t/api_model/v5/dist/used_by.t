use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Deep qw(cmp_deeply);

fixture {
    my @files = (
        'ISHIGAKI/JSON-PP-4.02.tar.gz',
        'SKAJI/Perl-Build-1.29.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    load_task('Traverse')->run(qw/ISHIGAKI SKAJI/);
    load_task('Analyze')->run(@files);
    load_task('PostProcess::UpdateReverseDependency')->run;
};

my $model = api_model('V5::Dist::UsedBy');

my @params = (
    [dist    => { name => 'JSON-PP' }],
    [release => { name => 'JSON-PP-4.02', pause_id => 'ISHIGAKI' }],
);

for my $param (@params) {
    my ($name, $load_arg) = @$param;
    my $subtest = sub ($load_arg) {
        return sub {
            my $res = $model->load($load_arg);
            cmp_deeply $res => {
                'data' => [{
                    'author'       => 'SKAJI',
                    'date'         => '2018-12-21',
                    'name_version' => 'Perl-Build-1.29',
                    'score'        => '100'
                }],
                'recordsTotal' => 1
            };
        };
    };
    subtest $name => $subtest->($load_arg);
}

done_testing;
