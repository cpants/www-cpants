use Mojo::Base -strict;
use FindBin;
use Test::More;
use Test::CPANfile 0.07;

my @extlibs = glob "$FindBin::Bin/../extlib/*/lib";
require lib; lib->import(@extlibs);

cpanfile_has_all_used_modules(
    parsers      => [':bundled'],
    scan_also    => \@extlibs,
    use_index    => 'Mirror',
    recommends   => 1,
    suggests     => 1,
    develop      => 1,
    exclude_core => 1,
    perl_version => '5.028',
    private_re   => qr/Module::CPANTS::(Site)?Kwalitee/,
    features     => {
        extlib => {
            paths => \@extlibs,
        },
    },
);

done_testing;
