use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

plan skip_all => "This test doesn't work well under Windows" if $^O eq 'MSWin32';

test_kwalitee(
    'no_symlinks',
    ['CMORRIS/Parse-Extract-Net-MAC48-0.01.tar.gz',          0],    # 3094
    ['BRUMLEVE/autobless-1.0.1.tar.gz',                      0],    # 3318
    ['BRUMLEVE/wildproto-1.0.1.tar.gz',                      0],    # 3617
    ['BRUMLEVE/vm-1.0.1.tar.gz',                             0],    # 4236
    ['CRUSOE/Template-Plugin-Filter-ANSIColor-0.0.3.tar.gz', 0],    # 4963
    ['GSLONDON/Devel-AutoProfiler-1.200.tar.gz',             0],    # 6139
    ['PHAM/Business-Stripe-0.04.tar.gz',                     0],    # 6412
    ['GAVINC/Config-Directory-0.05.tar.gz',                  0],    # 8774
    ['NETVARUN/Net-Semantics3-0.10.tar.gz',                  0],    # 8930
    ['GAVINC/File-DirCompare-0.7.tar.gz',                    0],    # 9018
);

done_testing;
