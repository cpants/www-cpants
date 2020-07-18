use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'proper_libs',
    # pm files not in the lib/base dir
    ['NIELSD/Speech-Google-0.5.tar.gz', 0],    # 2907 (Google/TTS.pm)

    # didn't extract nicely (dot underscore files)
    ['AQUILINA/WWW-LaQuinta-Returns-0.02.tar.gz', 0],    # 4055

    # multiple pm files in the basedir
    ['DGRAHAM/simpleXMLParse/simplexmlparse_v1.4.tar.gz', 0],    # 4336

    # no modules
    ['LAWSONK/Gtk2-Ex-MPlayerEmbed-0.03.tar.gz', 1],             # 465
    ['WOLDRICH/App-epic-0.014.tar.gz',           1],             # 812
    ['TAG/AnyEvent-Peer39-0.32.tar.gz',          1],             # 824
    ['CASIANO/Git-Export-0.04.tar.gz',           1],             # 2593
    ['MILOVIDOV/APP-Yatranslate-0.02.tar.gz',    1],             # 3773
    ['DBR/pdoc-0.900.tar.gz',                    1],             # 3876
    ['MUIR/modules/rinetd.pl-1.2.tar.gz',        1],             # 4319
);

done_testing;
