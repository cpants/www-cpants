use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'test_prereq_matches_use',
    ['STEVAN/decorators-0.01.tar.gz',    0],    # Test::Fatal
    ['MANOWAR/WWW-KeenIO-0.02.tar.gz',   0],    # Test::Mouse
    ['JLMARTIN/CloudDeploy-1.05.tar.gz', 0],    # File::Slurp etc
    ['YANICK/Bread-Board-0.36.tar.gz',   0],    # Moo
);

done_testing;
