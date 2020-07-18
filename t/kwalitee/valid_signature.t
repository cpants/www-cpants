use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use Test::RequiresInternet ('pool.sks-keyservers.net' => 80);

test_kwalitee(
    'valid_signature',
    ['HUGUEI/Net-Stomp-Receipt-0.36.tar.gz',               0],    # 3686
    ['JJORE/perl-lint-mode-0.02.tar.gz',                   0],    # 4391
    ['SIMON/Lingua-EN-Keywords-2.0.tar.gz',                0],    # 4639
    ['RPAGITSCH/Win32-Process-User-0.02.tar.gz',           0],    # 5063
    ['HUGUEI/Finance-Currency-Convert-BChile-0.04.tar.gz', 0],    # 5108
    [
        'RKOBES/File-HomeDir-Win32-0.04.tar.gz',
        0,
        sub {
            my $stash = shift;
            ok $stash->{error}{valid_signature};
        }
    ],
    [
        'RIVY/Win32-CommandLine-0.938.tar.gz',
        1,
        sub {
            my $stash = shift;
            like $stash->{error}{valid_signature} => qr/Old SIGNATURE detected/;
        }
    ],

    # No public key: May take a long time sometimes
    ['CRAIHA/Geo-Coordinates-Parser-0.01.tar.gz',                         0],    # 4009
    ['DMAKI/Class-Validating-0.02.tar.gz',                                0],    # 4624
    ['PELAGIC/List-Rotation-Cycle-1.009.tar.gz',                          0],    # 4648
    ['JMEHNLE/net-address-ipv4-local/Net-Address-IPv4-Local-0.12.tar.gz', 0],    # 4848
);

done_testing;
