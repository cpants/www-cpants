use Mojo::Base -strict, -signatures;
use FindBin;
use lib "$FindBin::Bin/lib";
use lib glob "extlib/*/lib";
use WWW::CPANTS::API;
use Plack::Builder;

my $api = WWW::CPANTS::API->new;

builder {
    enable 'ReverseProxy';
    $api->start('psgi');
};
