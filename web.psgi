use Mojo::Base -strict, -signatures;
use FindBin;
use lib "$FindBin::Bin/lib";
use lib glob "extlib/*/lib";
use WWW::CPANTS::Web;
use Plack::Builder;

my $web = WWW::CPANTS::Web->new;

builder {
    enable 'ReverseProxy';
    $web->start('psgi');
};
