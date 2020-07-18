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
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
};

my $model = api_model('V5::Kwalitee');

subtest 'mine' => sub {
    my $res = $model->load({});

    # too big and too fragile for eq_or_diff
    for my $type (qw/core extra experimental/) {
        ok exists $res->{data}{ $type . '_indicators' }, "data for $type indicator exists";
    }
    ok !grep { $_->{backpan_fails} } $res->{data}{core_indicators}->@*;
    ok grep  { $_->{backpan_fails} } $res->{data}{extra_indicators}->@*;
    ok grep  { $_->{backpan_fails} } $res->{data}{experimental_indicators}->@*;
};

done_testing;
