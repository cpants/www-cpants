use WWW::CPANTS;
use WWW::CPANTS::Test;

test_kwalitee(
    'meta_yml_declares_perl_version',
    ['TOBYINK/Platform-Windows-0.002.tar.gz',               0],    # 2206
    ['TOBYINK/Platform-Unix-0.002.tar.gz',                  0],    # 2264
    ['COOLMEN/Test-More-Color-0.04.tar.gz',                 0],    # 2963
    ['TXH/Template-Plugin-Filter-MinifyHTML-0.02.tar.gz',   0],    # 3484
    ['SMUELLER/Math-SymbolicX-Complex-1.01.tar.gz',         0],    # 4719
    ['SMUELLER/Math-Symbolic-Custom-CCompiler-1.03.tar.gz', 0],    # 5244
    ['LTP/Game-Life-0.05.tar.gz',                           0],    # 6535
    ['KPEE/Carp-Growl-0.0.3.tar.gz',                        0],    # 6682
);

done_testing;
