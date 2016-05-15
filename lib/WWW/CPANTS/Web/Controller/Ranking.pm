package WWW::CPANTS::Web::Controller::Ranking;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use parent 'Mojolicious::Controller';

sub index ($c) {
  my $data = page('Ranking::FiveOrMore')->load or return $c->reply->not_found;
  $c->stash(cpants => $data);
  $c->render('ranking/five_or_more');
}

sub tab ($c) {
  my $page = $c->param('page') || 1;
  my $tab = $c->param('tab');
  my $tabclass = camelize($tab);
  return $c->reply->not_found unless $tabclass =~ /^[A-Za-z0-9]+$/;
  my $data = page("Ranking\::$tabclass")->load($page) or return $c->reply->not_found;
  my $format = $c->stash('format') // '';
  if ($format eq 'json') {
    return $c->render(json => $data->{data});
  }
  $c->stash(cpants => $data);
  $c->render("ranking/$tab");
}

1;
