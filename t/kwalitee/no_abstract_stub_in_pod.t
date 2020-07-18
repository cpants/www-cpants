use WWW::CPANTS;
use WWW::CPANTS::Test;

test_kwalitee(
    'no_abstract_stub_in_pod',
    # h2xs
    ['ERICW/Roll-1.0.tar.gz',                        0],    # 2188
    ['IEFREMOV/Statistics-CountAverage-0.02.tar.gz', 0],    # 2839
    ['HSLEE/Search-Equidistance-0.01.tar.gz',        0],    # 3142
    ['OPITZ/URL-Grab-1.4.tar.gz',                    0],    # 3210

    # Module::Starter etc
    ['IKEBE/WebService-Livedoor-Auth-0.01.tar.gz', 0],

    # Minilla
    ['NNUTTER/Git-Repository-Plugin-Gerrit-0.03.tar.gz', 0],
);

done_testing;
