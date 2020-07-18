use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'use_strict',
    ['TOBYINK/Platform-Windows-0.002.tar.gz',                 0],    # 2206
    ['TOBYINK/Platform-Unix-0.002.tar.gz',                    0],    # 2264
    ['SCILLEY/POE/Component/IRC/Plugin/IRCDHelp-0.02.tar.gz', 0],    # 3243
    ['ANANSI/Anansi-Library-0.02.tar.gz',                     0],    # 3365
    ['TXH/Template-Plugin-Filter-MinifyHTML-0.02.tar.gz',     0],    # 3484
    ['ANANSI/Anansi-ObjectManager-0.06.tar.gz',               0],    # 5246
    ['MARCEL/Web-Library-0.01.tar.gz',                        0],    # 7345
    ['PJB/Speech-Speakup-1.04.tar.gz',                        0],    # 7410
    ['TEMPIRE/Eponymous-Hash-0.01.tar.gz',                    0],    # 8503
    ['SULLR/Net-SSLGlue-1.03.tar.gz',                         0],    # 8720

    # use 5.012 and higher
    ['ZDM/Pharaoh-BootStrap-3.00.tar.gz',   1],                      # use 5.12.0
    ['MALLEN/Acme-Github-Test-0.03.tar.gz', 1],                      # use 5.014

    # no .pm files
    ['RCLAMP/cvn-0.02.tar.gz', 1],

    # .pod without package declaration
    ['ETHER/Moose-2.1209.tar.gz', 1],

    # v6 module inside a Perl 5 distribution
    ['NINE/Inline-Perl6-0.07.tar.gz', 1],
);

done_testing;
