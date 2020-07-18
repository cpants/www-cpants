use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'meta_yml_conforms_to_known_spec',
    # '<undef>' for 'Carp' is not a valid version.
    ['MATIU/WWW-AfinimaKi-0.1.tar.gz', 0],    # 518

    # 'HASH(0xb8924f0)' for 'repository' does not have a URL scheme
    ['JBERGER/Alien-GSL-0.01.tar.gz', 0],     # 556

    # License 'Public domain' is invalid (license)
    ['SEVEAS/Term-Multiplexed-0.2.2.tar.gz', 0],    # 1683

    # Missing mandatory field, 'author' (author)
    ['ANDK/CPAN-Test-Dummy-Perl5-Make-CircDepeOne-1.00.tar.gz', 0],    # 1893

    # 'ExtUtils::MakeMaker version 6.17' for 'generated_by' is not a valid version. (requires -> generated_by)
    ['MITTI/PDF-Report-Table-1.00.tar.gz', 0],                         # 2300

    # Expected a map structure from string or file. (requires)
    ['ANDK/CPAN-Test-Dummy-Perl5-Make-Expect-1.00.tar.gz', 0],         # 2323

    # 'DateTime::Event::Easter' for 'Time::Piece' is not a valid version.
    ['CLIFFORDJ/Date-Holidays-EnglandWales-0.01.tar.gz', 0],           # 3085

    # Key 'Acme::Unic<&ouml>de' is not a legal module name.
    ['SCHWIGON/acme-unicode/Acme-Uenicoede-0.0501.tar.gz', 0],         # 3651

    # 'meta-spec' => '1.1' is kind of broken, but it's not regarded
    # as a fatal error as of CPAN::Meta 2.132830.
    ['JOSEPHW/XML-Writer-0.545.tar.gz', 1],
);

done_testing;
