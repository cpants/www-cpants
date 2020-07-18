use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'no_files_to_be_skipped',
    ['ABELTJE/Test-DBIC-SQLite-0.01.tar.gz',               0],    # 4821
    ['GTERMARS/Data-FormValidator-EmailValid-0.05.tar.gz', 0],    # 5597
    ['LARION/Lingua-Translator-Microsoft-1.1.1.tar.gz',    0],    # 6794
    ['MANWAR/Devel-Timer-0.11.tar.gz',                     0],    # 8150
    ['MIKEH/Bundle-Interchange-1.08.tar.gz',               0],    # 2564
    ['MOOCOW/Alien-Moot-0.003.tar.gz',                     0],    # 3384
    ['RSN/ORDB-DebianModules-Generator-0.02.tar.gz',       0],    # 3854
    ['SREZIC/Geo-Coder-Googlev3-0.17.tar.gz',              0],    # 8640
    ['TOBYINK/Alien-LibXML-0.004.tar.gz',                  0],    # 9119
    ['TOMK/lib-archive-0.3.tar.gz',                        0],    # 8196
);

done_testing;
