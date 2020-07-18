use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'extractable',
    ['JHI/Statistics-DEA-0.04.tar.gz',         -100],    # 3468
    ['JACKS/CallerItem-1.0.tar.gz',            -100],    # 3479
    ['ACESTER/Math-GMatrix-0.2.tar.gz',        -100],    # 3775
    ['JACKS/AlarmCall-1.1.tar.gz',             -100],    # 3858
    ['JKAST/StatisticsDescriptive-1.1.tar.gz', -100],    # 4098
    ['JHI/Statistics-Frequency-0.03.tar.gz',   -100],    # 4271
    ['MPOCOCK/GIFgraphExtensions-1.0.tar.gz',  -100],    # 4815
    ['SWORDSMAN/TSM_0.60.tar.gz',              -100],    # 5321
    ['STBEY/DFA-Kleene-1.0.tar.gz',            -100],    # 5353

    # invalid header blocks
    ['BLCKSMTH/String-RexxParse-1.10.tar.gz', -100],
    ['GROMMEL/Acme-Turing-0.02.tar.gz',       -100],

    # link errors
    ['KAMIPO/autobox-String-Inflector-0.02.tar.gz', -100],
    ['KAZUHO/DBIx-Replicate-0.04.tar.gz',           -100],
);

done_testing;
