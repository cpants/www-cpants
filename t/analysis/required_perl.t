use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use Test::More;

test_analysis(
    '/required_perl',
    # test requires 5.006, runtime recommends 5.008, declared runtime requires 5.008008
    ['HUGMEIR/Params-Lazy-0.005.tar.gz', '5.008008'],

    # declared runtime requires 5.006, test requires v5.18.1, runtime requires v5.18.2
    ['HUGMEIR/MariaDB-NonBlocking-0.20.tar.gz', '5.018002'],

    # declared runtime requires 5.008005, runtime requires 5.010001
    ['NIKOLAS/Shout-2.1.4.tar.gz', '5.010001'],

    # declared runtime requires 5.008001
    ['PALIK/Gearman-2.004.015.tar.gz', '5.008001'],

    # runtime requires 5.026_000
    ['VBAR/Regexp-Compare-0.31.tar.gz', '5.026000'],

    # declared runtime requires 0
    ['SEBNOW/ResourcePool-Resource-Redis-1.tar.gz', undef],
);

done_testing;
