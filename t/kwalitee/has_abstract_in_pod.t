use WWW::CPANTS;
use WWW::CPANTS::Test;

test_kwalitee(
    'has_abstract_in_pod',
    ['HACHI/MogileFS-Plugin-MetaData-0.01.tar.gz',  0],    # 2059
    ['URI/Acme-Madness-1.00.tar.gz',                0],    # 2090
    ['PJF/Payroll-AU-PAYG-0.01.tar.gz',             0],    # 2097
    ['LLAP/Plack-Middleware-OptionsOK-0.01.tar.gz', 0],    # 2117
    ['GMCCAR/Acme-ManekiNeko-0.03.tar.gz',          0],    # 2161
    ['KALEYCHEV/Math-Combination_out-0.21.tar.gz',  0],    # 2163
    ['LEOCHARRE/Getopt-Std-Strict-1.01.tar.gz',     0],    # 2165
    ['TJC/CGI-Untaint-telephone-0.03.tar.gz',       0],    # 2178
    ['STRZELEC/CGI-SpeedUp-0.11.tar.gz',            0],    # 2187

    # has a dash, though not in the same line as the package
    ['HODEL/Brasil-Checar-CGC-1.01a.tar.gz', 0],           # 2018

    # abstract in non-.pm file
    ['LEONT/App-find2perl-1.003.tar.gz', 1],

    # invalid =encoding (utf-8;)
    ['INGY/IO-All-0.40.tar.gz', 0],
);

done_testing;
