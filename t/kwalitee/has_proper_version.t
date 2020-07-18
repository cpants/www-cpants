use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'has_proper_version',
    ['WINTRU/Mica-1.a.0.tar.gz',                           0],    # 1196
    ['TSUNODA/Sledge-Plugin-SNMP-0.01a.tar.gz',            0],    # 1767
    ['TIMA/Bundle-Melody-Test-0.9.6a.tar.gz',              0],    # 2042
    ['CFABER/libuuid-perl_0.02.orig.tar.gz',               0],    # 2091
    ['DANPEDER/MIME-Base32-1.02a.tar.gz',                  0],    # 3136
    ['MOBILEART/Net-OmaDrm-0.10a.tar.gz',                  0],    # 3208
    ['ASKADNA/CGI-Application-Plugin-Eparam-0.04f.tar.gz', 0],    # 3228
    ['SPECTRUM/Math-BigSimple-1.1a.tar.gz',                0],    # 3269
    ['TSKIRVIN/HTML-FormRemove-0.3a.tar.gz',               0],    # 3625
    ['SHY/Wifi/Wifi-0.01a.tar.gz',                         0],    # 3767
);

done_testing;
