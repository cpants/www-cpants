use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'has_meta_json',
    ['AANOAA/WebService-Naver-TTS-v0.0.3.tar.gz',                   0],    # 3610
    ['DLIMA/Business-BR-CNJ-0.01.tar.gz',                           0],    # 2419
    ['INA/Fake/Our/Fake-Our-0.12.tar.gz',                           0],    # 7333
    ['JJNAPIORK/Catalyst-Plugin-DBIC-ConsoleQueryLog-0.002.tar.gz', 0],    # 9867
    ['KORSANI/Log-Funlog-Lang-0.4.tar.gz',                          0],    # 3472
    ['MASAKYST/Acme-Kiyoshi-Array-0.01.tar.gz',                     0],    # 8628
    ['RRVCKU/Lingua-Stem-Uk-0.01.tar.gz',                           0],    # 4724
    ['RSN/IO-All-SFTP-0.01.tar.gz',                                 0],    # 2720
    ['TTNDY/Sendmail-AbuseIPDB-0.10.tar.gz',                        0],    # 6078
    ['VVELOX/Log-Colorize-Helper-0.1.1.tar.gz',                     0],    # 5890
);

done_testing;
