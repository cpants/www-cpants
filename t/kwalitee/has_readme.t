use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'has_readme',
    ['SEVEAS/Term-Multiplexed-0.1.0.tar.gz',              0],    # 1701
    ['SROMANOV/App-Nopaste-Service-Dpaste-0.01.tar.gz',   0],    # 2448
    ['SROMANOV/Games-Chess-Position-Unicode-0.01.tar.gz', 0],    # 2629
    ['NIELSD/Speech-Google-0.5.tar.gz',                   0],    # 2907
    ['BOOK/Bundle-MetaSyntactic-1.026.tar.gz',            0],    # 3178
    ['BENMEYER/Finance-btce-0.02.tar.gz',                 0],    # 3575
    ['SYSADM/Mojolicious-Plugin-DeCSRF-0.94.tar.gz',      0],    # 3654
    ['BKB/Lingua-EN-PluralToSingular-0.06.tar.gz',        0],    # 3747
    ['MANIGREW/SEG7-1.0.1.tar.gz',                        0],    # 3847
    ['BKB/Lingua-JA-Gairaigo-Fuzzy-0.02.tar.gz',          0],    # 4159
);

done_testing;
