package WWW::CPANTS::Web::Controller::Kwalitee;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use parent 'Mojolicious::Controller';

sub index ($c) {
  my $data = page('Kwalitee')->load or return $c->reply->not_found;
  my $format = $c->stash('format') // '';
  if ($format eq 'json') {
    return $c->render(json => $data->{data});
  }
  $c->stash(cpants => $data);
  $c->render('kwalitee');
}

sub indicator ($c) {
  my $name = $c->param('name');
  my $data = page('Kwalitee::Indicator')->load($name) or return $c->reply->not_found;
  my $format = $c->stash('format') // '';
  if ($format eq 'json') {
    return $c->render(json => $data->{data});
  }
  $c->stash(cpants => $data);
  $c->render('kwalitee/indicator');
}

sub tab ($c) {
  my $name = $c->param('name');
  my $tab = $c->param('tab');
  my $tabclass = camelize($tab);
  my $page = $c->param('page') // 1;
  my $data = page("Kwalitee\::$tabclass")->load($name, $page) or return $c->reply->not_found;
  my $format = $c->stash('format') // '';
  if ($format eq 'json') {
    return $c->render(json => $data->{data});
  }
  $c->stash(cpants => $data);
  $c->render("kwalitee/$tab");
}

1;
