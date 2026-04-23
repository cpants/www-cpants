use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'has_contributing_doc',

    # CONTRIBUTING
    ['JBERGER/Test-Mojo-WithRoles-0.02.tar.gz', 1],

    # CONTRIBUTING.md
    ['MRDVT/Math-Round-SignificantFigures-0.02.tar.gz', 1],

    # CONTRIBUTING.pod
    ['PACMAN/Method-Extension-0.2.tar.gz', 1],

    # multiple CONTRIBUTING files (.md, .pod)
    ['MRDVT/Package-Role-ini-0.07.tar.gz', 1],

    ['BRIANDFOY/Tie-Timely-1.026.tar.gz', 0],
);

done_testing;
