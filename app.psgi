use Mojo::Base -strict, -signatures;
use FindBin;
use lib "$FindBin::Bin/lib";
use lib glob "extlib/*/lib";
use WWW::CPANTS::Web;
use WWW::CPANTS::API;
use Plack::Builder;
use Plack::App::URLMap;

my $web = WWW::CPANTS::Web->new;
my $api = WWW::CPANTS::API->new;
my $map = Plack::App::URLMap->new;
$map->map("/"    => $web->start('psgi'));
$map->map("/api" => $api->start('psgi'));

builder {
    enable 'ReverseProxy';
    $map->to_app;
};
