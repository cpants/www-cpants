use WWW::CPANTS;
use WWW::CPANTS::Test;

test_kwalitee(
    'no_dot_dirs',
    # .svn
    ['WAZZUTEKE/Net-Twitter-RandomUpdate-1.2.tar.gz', 0],    # 4710
    ['HOVENKO/HTML-ScriptLoader-1.00.tar.gz',         0],    # 5160

    # .git
    ['EXODIST/local-lib-deps-0.02.tar.gz',    0],            # 11662
    ['AQUILINA/Acme-Warn-LOLCAT-0.01.tar.gz', 0],            # 12638

    # .hg
    ['LICHTKIND/Tie-Wx-Widget-0.5.tar.gz', 0],               # 15259

    # .bzr
    ['GOOZBACH/asterisk-store/Asterisk-Store-Queue-Member-0.1.tar.gz', 0],    # 19811

    # others
    ['BRENDAN/Test-Mimic-0.009007.tar.gz',  0],                               # 11809
    ['PJF/Exobrain-Twitter-1.00.tar.gz',    0],                               # 16734
    ['MUENALAN/Workflow-Aline-0.03.tar.gz', 0],                               # 24529
    ['NACHBAUR/Test-Story-0.07.tar.gz',     0],                               # 41977
    ['RKIES/ec-1.6.tar.gz',                 0],                               # 77537
    ['VVELOX/Toader-1.1.0.tar.gz',          0],                               # 99633
    ['BBYRD/DBIx-Class-0.08204_01.tar.gz',  0],                               # 697468
);

done_testing;
