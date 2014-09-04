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
use WWW::CPANTS::Extlib;
use WWW::CPANTS::Log ();
use WWW::CPANTS::Pages;
use WWW::CPANTS::StatusImage;
use WWW::CPANTS::Config;
use WWW::CPANTS::Util::Markdown ();
use Compress::Zlib;

$ENV{MOJO_REVERSE_PROXY} = 1;

if ($^O eq 'MSWin32') {
  app->mode('development');
  app->log->level('debug');
}
else {
  app->mode('production');
  app->log->level('error');
}
app->secrets([random_regex('\w{40}')]);

app->helper(page_title => sub {
  my $self = shift;
  $self->stash('page_title') ||
  join ' - ', map {$_->{name}} @{$self->stash('breadcrumbs') || []};
});
app->helper(markdown => sub {
  my $self = shift;
  WWW::CPANTS::Util::Markdown::markdown(@_);
});

# ------------ For Browsers -----------------

under sub {
  my $self = shift;
  for my $event (qw/maintenance analyzing/) {
    if (appfile('__'.$event.'__')->exists) {
      $self->stash("notice_$event" => 1);
      last;
    }
  }
  return 1;
};

get '/' => sub {
  my $self = shift;
  my $page = page('Home');
  my $data = $page->load_data or return $self->render_not_found;
  $self->stash($data);
  $self->stash(page_title => $page->title);
} => 'home';

get '/author/:id/feed' => sub {
  my $self = shift;
  my $id = uc $self->param('id');
  my $base = $self->req->url->clone->to_abs->base;
  my $data = load_page('Author::Feed', $id, $base) or return $self->render_not_found;
  $self->render(format => 'atom', text => $data);
};

get '/author/:id/:tab' => sub {
  my $self = shift;
  my $id = uc $self->param('id');
  my $tab = $self->param('tab');
  my $tabclass = camelize($tab);
  return $self->render_not_found unless $tabclass =~ /^[A-Za-z0-9]+$/;
  my $data = load_page("Author\::$tabclass", $id) or return $self->render_not_found;
  my $format = $self->stash('format') || '';
  if ($format eq 'json') {
    return $self->render(json => $data);
  }
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
  $self->stash(breadcrumbs => [
    {name => $id, path => "/author/$id"},
    {name => $tabclass},
  ]);
  $self->stash(body_class => lc "pause-$id");
  $self->render("author/$tab");
};

get '/author/:id' => sub {
  my $self = shift;
  my $id = uc $self->param('id');
  my $base = $self->req->url->clone->to_abs->base;
  my $page = page('Author::Overview');
  my $data = $page->load_data($id) or return $self->render_not_found;
  my $format = $self->stash('format') || '';
  if ($format eq 'json') {
    return $self->render(json => $data);
  }
  if ($format eq 'png') {
    my $kwalitee = $data->{author_info}{average_core_kwalitee};
    my $path = WWW::CPANTS::StatusImage->new($kwalitee)->path;
    return $self->render_static($path);
  }
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
  $self->stash(breadcrumbs => [
    {name => $id},
  ]);
  $self->stash(page_title => "$data->{author_info}{name} ($id)");
  $self->stash(feed_title => "Feed for $id");
  $self->stash(feed_url => "$base/author/$id/feed");
  $self->stash(body_class => lc "pause-$id");
} => 'author/overview';

get '/authors' => sub {
  my $self = shift;
  $self->stash(authors => []);
  $self->stash(breadcrumbs => [
    {name => page('Authors')->title},
  ]);
} => 'authors';

post '/authors' => sub {
  my $self = shift;
  my $name = $self->param('name');
  my $page = page('Authors');
  my $data = $page->load_data($name);
  if (@{$data->{authors}} == 1) {
    $self->redirect_to('/author/'.$data->{authors}[0]{pauseid});
    return;
  }
  $self->stash(name => $name);
  $self->stash($data);
  $self->stash(breadcrumbs => [
    {name => $page->title},
  ]);
} => 'authors';

get '/dist/#distname' => sub {
  my $self = shift;
  my $name = $self->param('distname');
  my $format = '';
  if ($name =~ s/\.(json|png)$//) {
    $format = $1;
    $self->param(distname => $name);
    $self->stash(format => $format);
  }
  my $data = load_page('Dist::Overview', $name) or return $self->render_not_found;
  if ($format eq 'json') {
    return $self->render(json => $data);
  }
  if ($format eq 'png') {
    my $kwalitee = $data->{dist}{kwalitee};
    my $path = WWW::CPANTS::StatusImage->new($kwalitee)->path;
    return $self->render_static($path);
  }
  $self->stash($data);
  $self->stash(requires_highcharts => 1);
  $self->stash(requires_tablesorter => 1);
  $self->stash(breadcrumbs => [
    {name => $name},
  ]);
} => 'dist/overview';

get '/dist/#distname/:tab' => sub {
  my $self = shift;
  my $name = $self->param('distname');
  my $tab = $self->param('tab');
  my $tabclass = camelize($tab);
  return $self->render_not_found unless $tabclass =~ /^[A-Za-z0-9]+$/;
  my $page = $self->param('page');
  my $data = load_page("Dist\::$tabclass", $name, $page) or return $self->render_not_found;
  my $format = $self->stash('format') || '';
  if ($format eq 'json') {
    return $self->render(json => $data);
  }
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
  $self->stash(breadcrumbs => [
    {name => $name, path => "/dist/$name"},
    {name => $tabclass},
  ]);
  $self->render("dist/$tab");
};

get '/dists' => sub {
  my $self = shift;
  $self->stash(dists => []);
  $self->stash(breadcrumbs => [
    {name => page('Dists')->title},
  ]);
} => 'dists';

post '/dists' => sub {
  my $self = shift;
  my $name = $self->param('name');
  my $page = page('Dists');
  my $data = $page->load_data($name);
  if (@{$data->{dists}} == 1) {
    $self->redirect_to('/dist/'.$data->{dists}[0]);
    return;
  }
  $self->stash(name => $name);
  $self->stash($data);
  $self->stash(breadcrumbs => [
    {name => $page->title},
  ]);
} => 'dists';

get '/ranking' => sub {
  my $self = shift;
  my $page = page('Ranking');
  my $data = $page->load_data;
  $self->stash($data);
  $self->stash(breadcrumbs => [
    {name => $page->title},
  ]);
} => 'ranking';

get '/ranking/:tab' => sub {
  my $self = shift;
  my $page_no = $self->param('page') || 1;
  my $tab = $self->param('tab');
  my $tabclass = camelize($tab);
  return $self->render_not_found unless $tabclass =~ /^[A-Za-z0-9]+$/;
  my $parent = page('Ranking');
  my $page = page("Ranking\::$tabclass") or return $self->render_not_found;
  my $data = $page->load_data($page_no) or return $self->render_not_found;
  my $format = $self->stash('format') || '';
  if ($format eq 'json') {
    return $self->render(json => $data);
  }
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
  $self->stash(breadcrumbs => [
    {name => $parent->title, path => '/ranking'},
    {name => $page->title},
  ]);
  $self->render("ranking/$tab");
};

get '/kwalitee' => sub {
  my $self = shift;
  my $page = page('Kwalitee');
  my $data = $page->load_data or return $self->render_not_found;
  my $format = $self->stash('format') || '';
  if ($format eq 'json') {
    return $self->render(json => $data);
  }
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
  $self->stash(breadcrumbs => [
    {name => $page->title},
  ]);
} => 'kwalitee/overview';

get '/kwalitee/:name' => sub {
  my $self = shift;
  my $name = $self->param('name');
  my $parent = page('Kwalitee');
  my $data = load_page('Kwalitee::Indicator', $name) or return $self->render_not_found;
  my $format = $self->stash('format') || '';
  if ($format eq 'json') {
    return $self->render(json => $data);
  }
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
  $self->stash(requires_highcharts => 1);
  $self->stash(breadcrumbs => [
    {name => $parent->title, path => '/kwalitee'},
    {name => $name},
  ]);
} => 'kwalitee/indicator';

get '/stats' => sub {
  my $self = shift;
  my $page = page('Stats');
  my $data = $page->load_data;
  $self->stash($data);
  $self->stash(breadcrumbs => [
    {name => $page->title},
  ]);
} => 'stats';

get '/stats/:tab' => sub {
  my $self = shift;
  my $tab = $self->param('tab');
  my $tabclass = length $tab < 3 ? uc($tab) : camelize($tab);
  return $self->render_not_found unless $tabclass =~ /^[A-Za-z0-9]+$/;
  my $parent = page('Stats');
  my $page = page("Stats\::$tabclass") or return $self->render_not_found;
  my $data = $page->load_data or return $self->render_not_found;
  my $format = $self->stash('format') || '';
  if ($format eq 'json') {
    return $self->render(json => $data);
  }
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
  $self->stash(breadcrumbs => [
    {name => $parent->title, path => '/stats'},
    {name => $page->title},
  ]);
  $self->render("stats/$tab");
};

get '/recent' => sub {
  my $self = shift;
  my $page = page('Recent');
  my $data = $page->load_data or return $self->render_not_found;
  my $format = $self->stash('format') || '';
  if ($format eq 'json') {
    return $self->render(json => $data);
  }
  $self->stash($data);
  $self->stash(breadcrumbs => [
    {name => $page->title},
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
  return if $c->res->content->is_multipart || $c->res->content->is_dynamic;

  my $asset = $c->res->content->asset;
  return if $asset->is_file || $asset->is_range;
  my $content = $asset->slurp;
  $c->res->headers->content_encoding('gzip');
  $c->res->body(Compress::Zlib::memGzip($content));
};

builder {
  if (app->mode eq 'production') {
    enable "ReverseProxy";
    enable "ServerStatus::Lite",
      path => '/server-status',
      allow => WWW::CPANTS::Config->local_addr,
      counter_file => appdir('tmp/counter'),
      scoreboard => appdir('tmp/scoreboard')->mkpath;
  }
  enable "AxsLog",
    combined => 1,
    response_time => 1,
    long_response_time => 1000000,
    logger => sub { WWW::CPANTS::Log->log(alert => @_) };
  app->start;
};
