package WWW::CPANTS::Web;

use WWW::CPANTS;
use WWW::CPANTS::Util::Path;
use WWW::CPANTS::Web::Context;
use parent 'Mojolicious';
use Digest::MD5 qw/md5_hex/;

sub startup ($app) {
    $WWW::CPANTS::CONTEXT = WWW::CPANTS::Web::Context->new('web');
    $WWW::CPANTS::CONTEXT->load_config;

    if ($^O eq 'MSWin32') {
        $app->mode('development');
        $app->log->level('debug');
    } else {
        $app->mode('production');
        $app->log->level('error');
    }
    $app->secrets([md5_hex($$ . time)]);
    $app->plugin('WWW::CPANTS::Web::Plugin::Helpers');
    $app->plugin('WWW::CPANTS::Web::Plugin::Hooks');

    my $r = $app->routes->under('/')->to('root#check_maintenance');
    $r->get('/')->to('home#index');
    $r->get('/author/:id')->to('author#index');
    $r->get('/author/:id/feed')->to('author#feed');
    $r->get('/dist/#name')->to('dist#index');
    $r->get('/dist/#name/:tab')->to('dist#tab');
    $r->get('/release/:author/#name')->to('dist#index');
    $r->get('/release/:author/#name/:tab')->to('dist#tab');
    $r->get('/ranking')->to('ranking#index');
    $r->get('/ranking/:tab')->to('ranking#tab');
    $r->get('/kwalitee')->to('kwalitee#index');
    $r->get('/kwalitee/:name')->to('kwalitee#indicator');
    $r->get('/kwalitee/:name/:tab')->to('kwalitee#tab');
    $r->get('/stats')->to('stats#index');
    $r->get('/stats/:tab')->to('stats#tab');
    $r->get('/recent')->to('recent#index');
    $r->get('/search')->to('search#index');
    $r->post('/search')->to('search#search');
    $r->get('/about')->to('about#index');
    $r->get('/about/:tab')->to('about#tab');

    my $api = $r->under('/api')->to('api#check_xhr');

    my $api4 = $api->under('/v4');

    $api4->post('/search')->to('api-v4#search');

    # for data tables
    for my $type (
        qw/
        recent_releases
        recent_releases_by
        cpan_distributions_by
        ranking
        releases_of
        fails_in
        reverse_dependencies_of
        /
        )
    {
        $api4->get("/table/$type")->to("api-v4#$type");
    }
}

1;
