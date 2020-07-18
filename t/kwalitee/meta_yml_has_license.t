use WWW::CPANTS;
use WWW::CPANTS::Test;

test_kwalitee(
    'meta_yml_has_license',
    ['CHENGANG/Log-Lite-0.05.tar.gz',                         0],    # 2739
    ['SCILLEY/POE/Component/IRC/Plugin/IRCDHelp-0.02.tar.gz', 0],    # 3243
    ['ANANSI/Anansi-Library-0.02.tar.gz',                     0],    # 3365
    ['HITHIM/Socket-Mmsg-0.02.tar.gz',                        0],    # 3946
    ['FAYLAND/Acme-CPANAuthors-Chinese-0.26.tar.gz',          0],    # 4474
    ['BENNIE/ACME-KeyboardMarathon-1.15.tar.gz',              0],    # 4479
    ['ALEXP/Catalyst-Model-DBI-0.32.tar.gz',                  0],    # 4686
    ['YTURTLE/Nephia-Plugin-Response-YAML-0.01.tar.gz',       0],    # 4948
    ['CHENRYN/Nagios-Plugin-ByGmond-0.01.tar.gz',             0],    # 5159
    ['IAMCAL/Flickr-API-1.06.tar.gz',                         0],    # 5172
);

done_testing;
