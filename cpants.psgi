#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Mojolicious::Lite;
use Plack::Builder;
use String::Random 'random_regex';
use String::CamelCase 'camelize';
use WWW::CPANTS::AppRoot;
use WWW::CPANTS::Log ();
use WWW::CPANTS::Pages;
use WWW::CPANTS::Config;
use Compress::Zlib;

$ENV{MOJO_REVERSE_PROXY} = 1;

if ($^O eq 'MSWin32') {
  app->mode('development');
  app->log->level('debug');
}
else {
  app->mode('production');
  app->log->level('error');
  system($^X, appfile("minify.pl"));
}
app->secret(random_regex('\w{40}'));

# ------------ For Browsers -----------------

under sub {
  my $self = shift;
  if (appfile('__maintenance__')->exists) {
    $self->stash(under_maintenance => 1);
  }
  return 1;
};

get '/' => sub {
  my $self = shift;
  my $data = load_page('Home') or return $self->render_not_found;
  $self->stash($data);
} => 'home';

get '/author/:id/feed' => sub {
  my $self = shift;
  my $id = uc $self->param('id');
  my $base = $self->req->url->clone->to_abs->base;
  if (my $host = $self->req->headers->header('X-Forwarded-Host')) {
    my $host = (split /\s*,\s*/, $host)[0];
    $host =~ s/:([0-9]+)$//;
    my $port = $1 ? $1 : undef;
    $base->host($host);
    $base->port($port);
  }
  my $data = load_page('Author::Feed', $id, $base) or return $self->render_not_found;
  $self->render(format => 'atom', text => $data);
};

get '/author/:id' => sub {
  my $self = shift;
  my $id = uc $self->param('id');
  my $base = $self->req->url->clone->to_abs->base;
  if (my $host = $self->req->headers->header('X-Forwarded-Host')) {
    my $host = (split /\s*,\s*/, $host)[0];
    $host =~ s/:([0-9]+)$//;
    my $port = $1 ? $1 : undef;
    $base->host($host);
    $base->port($port);
  }
  my $data = load_page('Author', $id) or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
  $self->stash(breadcrumbs => [
    {name => 'Author'},
    {name => $id},
  ]);
  $self->stash(feed_title => "Feed for $id");
  $self->stash(feed_url => "$base/author/$id/feed");
  $self->stash(body_class => lc "pause-$id");
} => 'author';

get '/authors' => sub {
  my $self = shift;
  $self->stash(authors => []);
  $self->stash(breadcrumbs => [
    {name => 'Search Authors'},
  ]);
} => 'authors';

post '/authors' => sub {
  my $self = shift;
  my $name = $self->param('name');
  my $data = load_page('Authors', $name);
  if (@{$data->{authors}} == 1) {
    $self->redirect_to('/author/'.$data->{authors}[0]{pauseid});
    return;
  }
  $self->stash(name => $name);
  $self->stash($data);
  $self->stash(breadcrumbs => [
    {name => 'Search Authors'},
  ]);
} => 'authors';

get '/dist/#distname' => sub {
  my $self = shift;
  my $name = $self->param('distname');
  my $data = load_page('Dist::Overview', $name) or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_highcharts => 1);
  $self->stash(requires_tablesorter => 1);
  $self->stash(breadcrumbs => [
    {name => 'Distribution'},
    {name => $name},
  ]);
} => 'dist/overview';

get '/dist/#distname/:tab' => sub {
  my $self = shift;
  my $name = $self->param('distname');
  my $tab = $self->param('tab');
  my $tabclass = camelize($tab);
  return $self->render_not_found unless $tabclass =~ /^[A-Za-z0-9]+$/;
  my $data = load_page("Dist\::$tabclass", $name) or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
  $self->stash(breadcrumbs => [
    {name => 'Distribution'},
    {name => $name, path => "/dist/$name"},
    {name => $tabclass},
  ]);
  $self->render("dist/$tab");
};

get '/dists' => sub {
  my $self = shift;
  $self->stash(dists => []);
  $self->stash(breadcrumbs => [
    {name => 'Search Distributions'},
  ]);
} => 'dists';

post '/dists' => sub {
  my $self = shift;
  my $name = $self->param('name');
  my $data = load_page('Dists', $name);
  if (@{$data->{dists}} == 1) {
    $self->redirect_to('/dist/'.$data->{dists}[0]);
    return;
  }
  $self->stash(name => $name);
  $self->stash($data);
  $self->stash(breadcrumbs => [
    {name => 'Search Distributions'},
  ]);
} => 'dists';

get '/ranking' => sub {
  my $self = shift;
  $self->stash(breadcrumbs => [
    {name => 'Ranking'},
  ]);
} => 'ranking';

get '/ranking/:tab' => sub {
  my $self = shift;
  my $page = $self->param('page') || 1;
  my $tab = $self->param('tab');
  my $tabclass = camelize($tab);
  return $self->render_not_found unless $tabclass =~ /^[A-Za-z0-9]+$/;
  my $data = load_page("Ranking\::$tabclass", $page) or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
  $self->stash(breadcrumbs => [
    {name => 'Ranking', path => '/ranking'},
    {name => $tabclass},
  ]);
  $self->render("ranking/$tab");
};

get '/kwalitee' => sub {
  my $self = shift;
  my $data = load_page('Kwalitee') or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
  $self->stash(breadcrumbs => [
    {name => 'Kwalitee'},
  ]);
} => 'kwalitee/overview';

get '/kwalitee/:name' => sub {
  my $self = shift;
  my $name = $self->param('name');
  my $data = load_page('Kwalitee::Indicator', $name) or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
  $self->stash(requires_highcharts => 1);
  $self->stash(breadcrumbs => [
    {name => 'Kwalitee', path => '/kwalitee'},
    {name => $name},
  ]);
} => 'kwalitee/indicator';

get '/stats' => sub {
  my $self = shift;
  $self->stash(breadcrumbs => [
    {name => 'Stats'},
  ]);
} => 'stats';

get '/stats/:tab' => sub {
  my $self = shift;
  my $tab = $self->param('tab');
  my $tabclass = camelize($tab);
  return $self->render_not_found unless $tabclass =~ /^[A-Za-z0-9]+$/;
  my $data = load_page("Stats\::$tabclass") or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
  $self->stash(breadcrumbs => [
    {name => 'Stats', path => '/stats'},
    {name => $tabclass},
  ]);
  $self->render("stats/$tab");
};

get '/recent' => sub {
  my $self = shift;
  my $data = load_page("Recent") or return $self->render_not_found;
  $self->stash($data);
  $self->stash(breadcrumbs => [
    {name => 'Recent'},
  ]);
} => 'recent';

# ------------ API -----------------

under '/api' => sub {
  my $self = shift;

  return unless $self->req->is_xhr;
  # XXX: want some token?

  return 1;
};

post '/authors' => sub {
  my $self = shift;
  my $name = $self->param('name');
  my $data = load_page('Authors', $name);
  $self->render(json => $data);
};

post '/dists' => sub {
  my $self = shift;
  my $name = $self->param('name');
  my $data = load_page('Dists', $name);
  $self->render(json => $data);
};

get '/chart/author/:id' => sub {
  my $self = shift;
  my $id = $self->param('id');
  my $data = load_page('Author::Chart', $id);
  $self->render(json => $data);
};

get '/chart/dist/#distname' => sub {
  my $self = shift;
  my $name = $self->param('distname');
  my $data = load_page('Dist::Chart', $name);
  $self->render(json => $data);
};

get '/chart/kwalitee/overview' => sub {
  my $self = shift;
  my $data = load_page('Kwalitee::Chart::Overview');
  $self->render(json => $data);
};

get '/chart/kwalitee/:name' => sub {
  my $self = shift;
  my $name = $self->param('name');
  my $data = load_page('Kwalitee::Chart::Indicator', $name);
  $self->render(json => $data);
};

hook before_dispatch => sub {
  my $c = shift;

  return if $c->req->headers->header('X-Forwarded-For');

  return unless ($c->req->headers->accept_encoding || '') =~ /gzip/i;
  my $path = $c->stash->{path} || $c->req->url->path->clone->canonicalize;
  return unless my @parts = @{Mojo::Path->new("$path")->parts};
  return if $parts[0] eq '..';
  my $rel = join('/', @parts) . '.gz';
  if (my $file = app->static->file($rel)) {
    my $type = $rel =~ /\.(\w+)\.gz$/ ? app->types->type($1) : undef;
    $c->res->headers->content_type($type || 'text/plain');
    $c->res->headers->content_encoding('gzip');
    app->static->serve_asset($c, $file) or return undef;
    $c->stash->{'mojo.static'}++;
    return !!$c->rendered;
  }
};

hook after_dispatch => sub {
  my $c = shift;
  return if $c->stash->{'mojo.static'};
  return if $c->req->headers->header('X-Forwarded-For');
  return unless ($c->req->headers->accept_encoding || '') =~ /gzip/i;
  return if $c->res->is_multipart || $c->res->is_dynamic;

  my $asset = $c->res->content->asset;
  return if $asset->is_file || $asset->is_range;
  my $content = $asset->slurp;
  $c->res->headers->content_encoding('gzip');
  $c->res->body(Compress::Zlib::memGzip($content));
};

builder {
  if (app->mode eq 'production') {
    enable "ServerStatus::Lite",
      path => '/server-status',
      allow => WWW::CPANTS::Config->local_addr,
      counter_file => appdir('tmp/counter'),
      scoreboard => appdir('tmp/scoreboard')->mkpath;
  }
  enable "AxsLog",
    combined => 1,
    reponse_time => 1,
    long_response_time => 1000000,
    logger => sub { WWW::CPANTS::Log->log(alert => @_) };
  app->start;
};
