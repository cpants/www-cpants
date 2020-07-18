use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'no_unauthorized_packages',
    ['ECARROLL/URI-http-Dump-0.03.tar.gz',            0],    # URI::http
    ['PMAKHOLM/Devel-RemoteTrace-0.3.tar.gz',         0],    # DB
    ['SIMKIN/Apache-LoggedAuthDBI-0.12.tar.gz',       0],    # DBI etc
    ['WILLERT/Catalyst-Model-EmailStore-0.03.tar.gz', 0],    # Email::Store::DBI
    ['KNM/Ambrosia-0.010.tar.gz',                     0],    # deferred
    ['HACHI/MogileFS-Plugin-MetaData-0.01.tar.gz',    0],    # MogileFS::Store
);

done_testing;
