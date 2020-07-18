use WWW::CPANTS;
use WWW::CPANTS::Test;

test_kwalitee(
    'meta_json_conforms_to_known_spec',
    # scalar license
    ['DMAKI/XML-RSS-Liberal-0.04.tar.gz', 0],

    # no abstract
    ['MLEHMANN/AnyEvent-DBus-0.31.tar.gz', 0],

    # resource -> license
    ['BARBIE/Template-Plugin-Lingua-EN-NameCase-0.01.tar.gz', 0],

    # invalid license
    ['TOMO/src/Net-SMTPS-0.03.tar.gz',          0],    # perl
    ['RSAVAGE/DBIx-Admin-CreateTable-2.08.tgz', 0],    # artistic_2_0

    # 'origin' for 'repository' does not have a URL scheme
    ['RJBS/Sub-Import-0.092800.tar.gz',      0],
    ['MARCEL/Permute-Named-1.100980.tar.gz', 0],

    # '' for 'repository' is not a valid URL.
    ['KEEDI/Pod-Weaver-Section-Encoding-0.100830.tar.gz', 0],

    # git@github.com:... does not have a URL authority
    ['TIMB/PostgreSQL-PLPerl-Trace-1.001.tar.gz', 0],

    # Custom key must begin with 'x_' or 'X_'.
    ['AVAR/Bot-Twatterhose-0.04.tar.gz', 0],

    # value is an undefined string
    ['TOBYINK/Return-Type-0.004.tar.gz', 0],
);

done_testing;
