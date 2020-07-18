use Mojo::Base -strict, -signatures;
use FindBin;
use Test::More;
use WWW::CPANTS;
use Path::Tiny;

my $root = path("$FindBin::Bin/..")->realpath;

my $api_app_root = WWW::CPANTS->instance->app_root;
is $api_app_root => $root, "api app root";

done_testing;
