use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'no_mymeta_files',
    ['SZABGAB/File-Open-OOP-0.01.tar.gz',                               0],    # 2431
    ['JHTHORSEN/The-synthesizer-0.01.tar.gz',                           0],    # 2514
    ['TENGU/Catalyst-Authentication-Credential-MultiFactor-1.0.tar.gz', 0],    # 2577
    ['BDFOY/Psychic-Ninja-0.10_01.tar.gz',                              0],    # 2689
    ['JHTHORSEN/The-synthesizer-0.02.tar.gz',                           0],    # 2708
    ['ZZZ/Here-Template-0.1.tar.gz',                                    0],    # 2793
    ['KIMOTO/Mojolicious-Plugin-AutoRoute-0.04.tar.gz',                 0],    # 2811
    ['BDFOY/Net-SSH-Perl-WithSocks-0.02.tar.gz',                        0],    # 2894
    ['ZZZ/Here-Template-0.2.tar.gz',                                    0],    # 2902
    ['KIMOTO/Mojolicious-Plugin-AutoRoute-0.02.tar.gz',                 0],    # 2902
);

done_testing;
