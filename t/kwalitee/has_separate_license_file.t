use WWW::CPANTS;
use WWW::CPANTS::Test;

test_kwalitee(
    'has_separate_license_file',
    ['TOBYINK/Platform-Windows-0.002.tar.gz',       0],    # 2206
    ['TOBYINK/Platform-Unix-0.002.tar.gz',          0],    # 2264
    ['BOOK/Acme-MetaSyntactic-errno-1.003.tar.gz',  0],    # 2889
    ['COOLMEN/Test-More-Color-0.04.tar.gz',         0],    # 2963
    ['ANANSI/Anansi-Library-0.02.tar.gz',           0],    # 3365
    ['HITHIM/Socket-Mmsg-0.02.tar.gz',              0],    # 3946
    ['COOLMEN/Test-Mojo-More-0.04.tar.gz',          0],    # 4301
    ['MUGENKEN/Bundle-Unicheck-0.02.tar.gz',        0],    # 4596
    ['SMUELLER/Math-SymbolicX-Complex-1.01.tar.gz', 0],    # 4719
    ['CHENRYN/Nagios-Plugin-ByGmond-0.01.tar.gz',   0],    # 5159

    # LICENSE.txt (RT #114274)
    ['IKEGAMI/Syntax-Feature-Void-v1.0.0.tar.gz', 1],      #
);

done_testing;
