use WWW::CPANTS;
use WWW::CPANTS::Test;

my @tests = (
    ['DGL/Acme-mA-1337.1.tar.gz',                          0],    # 3411
    ['SCHWIGON/acme-unicode/Acme-Uenicoede-0.0501.tar.gz', 0],    # 3651
    ['DGL/Acme-3mxA-1337.37.tar.gz',                       0],    # 4093
    ['KOORCHIK/Mojolicious-Plugin-RenderFile-0.06.tar.gz', 0],    # 4114
);

# The followings are only valid for non-Win32 env
# (because invalid files will not be extracted on Win32).
push @tests, (
    ['PERFSONAR/perfSONAR_PS-Status-Common-0.09.tar.gz',    0],    # 5439
    ['PERFSONAR/perfSONAR_PS-Client-Echo-0.09.tar.gz',      0],    # 6654
    ['FRASE/Test-Builder-Clutch-0.05.tar.gz',               0],    # 6764
    ['PERFSONAR/perfSONAR_PS-DB-File-0.09.tar.gz',          0],    # 7704
    ['PERFSONAR/perfSONAR_PS-Client-LS-Remote-0.09.tar.gz', 0],    # 8232
) unless $^O eq 'MSWin32';

test_kwalitee('portable_filenames', @tests);

done_testing;
