use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'no_maniskip_error',
    # Unrecognized escape \i passed through in regex
    ['GARU/Net-TinyERP-0.05.tar.gz',  0],    # 9814
    ['GARU/Data-Printer-0.40.tar.gz', 0],    # 58847

    # Unrecognized escape \M passed through in regex
    ['FRANCKC/AnyEvent-Riak-0.01.tar.gz', 0],    # 3878

    # Quantifier follows nothing in regex
    ['DVWRIGHT/WWW-TasteKid-0.1.4.tar.gz', 0],    # 38770
    ['JANE/Data-TDMA-0.2.tar.gz',          0],    # 17907

    # ^* matches null string many times in regex
    ['MANWAR/Term-ProgressBar-2.22.tar.gz',                      0],    # 19506
    ['SCHWIGON/class-methodmaker/Class-MethodMaker-2.24.tar.gz', 0],    # 77242
);

done_testing;
