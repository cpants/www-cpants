use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'configure_prereq_matches_use',
    ['SAPER/Shell-Parser-0.04.tar.gz',                             0],    # Module::Build
    ['INFOFLEX/DBD_SQLFLEX_8.2.tar.gz',                            0],    # DBI etc
    ['TRIZK/Mail-SpamAssassin-Contrib-Plugin-IPFilter-1.2.tar.gz', 0],    # Devel::AssertOS
    ['FINNPERL/App-PerlXLock-0.08.tar.gz',                         0],    # Inline::Module
);

done_testing;
