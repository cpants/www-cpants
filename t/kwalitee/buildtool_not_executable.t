use WWW::CPANTS;
use WWW::CPANTS::Test;

plan skip_all => "This test doesn't work well under Windows" if $^O eq 'MSWin32';

test_kwalitee(
    'buildtool_not_executable',
    ['COOLMEN/Test-More-Color-0.04.tar.gz',        0],    # 2963
    ['CODECHILD/Thread-SharedTreeSet-0.01.tar.gz', 0],    # 3191
    ['CODECHILD/Set-Definition-0.01.tar.gz',       0],    # 4242
    ['JEEN/WebService-Aladdin-0.08.tar.gz',        0],    # 4287
    ['DSYRTM/Guitar-Scale-0.06.tar.gz',            0],    # 4469
    ['OVNTATAR/GitHub-Jobs-0.04.tar.gz',           0],    # 5322
    ['EGILES/X11-Terminal-v1.0.0.tar.gz',          0],    # 6205
    ['LTP/Game-Life-0.05.tar.gz',                  0],    # 6535
    ['LTP/IBM-SONAS-0.021.tar.gz',                 0],    # 7177
    ['DSYRTM/File-BetweenTree-1.02.tar.gz',        0],    # 7590
);

done_testing;
