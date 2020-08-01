use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use WWW::CPANTS::Util::JSON;
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

my $model = api_model('V5::Dist::Metadata');

my @params = (
    [dist    => { name => 'Test-CPANfile' }],
    [release => { name => 'Test-CPANfile-0.06', pause_id => 'ISHIGAKI' }],
);

for my $param (@params) {
    my ($name, $load_arg) = @$param;
    my $subtest = sub ($load_arg) {
        return sub {
            my $res = $model->load($load_arg);
            # too big and fragile to compare
            ok my $metadata = $res->{data}{metadata};
            ok eval { $metadata && decode_json($metadata) };
            note $@ if $@;
        };
    };
    subtest $name => $subtest->($load_arg);
}

done_testing;
