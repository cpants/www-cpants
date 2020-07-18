use Mojo::Base -strict, -signatures;
use FindBin;
use Test::More;
use File::Find;
use lib glob "$FindBin::Bin/../extlib/*/lib";

my $root = "$FindBin::Bin/..";

my $fail;
find({
        wanted => sub {
            my $file = $File::Find::name;
            my ($package) = $file =~ m!lib/(.+)\.pm$!;
            return unless $package;
            $package =~ s|/|::|g;
            require_ok $package or $fail++;
        },
        no_chdir => 1,
    },
    "$root/lib"
);

require_ok "$root/api.psgi" or $fail++;

BAIL_OUT if $fail;

done_testing;
