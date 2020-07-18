use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'has_known_license_in_source_file',
    ['JJUDD/DBIx-Class-TimeStamp-HiRes-v1.0.0.tar.gz', 0],    # 2596
    ['ANANSI/Anansi-Library-0.02.tar.gz',              0],    # 3365
    ['SMUELLER/Math-SymbolicX-Complex-1.01.tar.gz',    0],    # 4719
    ['IAMCAL/Flickr-API-1.06.tar.gz',                  0],    # 5172

    # =head1 AUTHOR / COPYRIGHT / LICENSE
    ['BJOERN/AI-CRM114-0.01.tar.gz', 1],

    # has =head1 COPYRIGHT AND LICENSE without closing =cut
    ['DAMI/DBIx-DataModel-2.39.tar.gz', 1],

    # has =head1 LICENSE followed by =head1 COPYRIGHT
    ['YSASAKI/App-pfswatch-0.08.tar.gz', 1],

    # ignore inc/Devel/CheckLib
    ['DJERIUS/Lua-API-0.02.tar.gz', 1],

    # https://github.com/cpants/www-cpants/issues/44
    ['NEILB/Business-CCCheck-0.09.tar.gz', 1],
);

done_testing;
