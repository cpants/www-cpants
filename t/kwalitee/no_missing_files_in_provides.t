use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'no_missing_files_in_provides',
    ['MIYAGAWA/CPAN-Test-Dummy-Perl5-DifferentProvides-0.01.tar.gz', 0],    # 9453

    ['LNATION/Moonshine-Bootstrap-0.01.tar.gz',    0],                      # 4621
    ['MANWAR/WWW-Google-APIDiscovery-0.23.tar.gz', 0],                      # 9876

    # trailing comma
    ['DFARRELL/stasis-0.07.tar.gz', 0],                                     # 4705

    # inconsistent case
    ['PINE/SemVer-V2-Strict-0.13.tar.gz', 0],                               # 8597
);

done_testing;
