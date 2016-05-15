package WWW::CPANTS::Web::Controller::Search;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use parent 'Mojolicious::Controller';

sub index ($c) {
  $c->render('search');
}

sub search ($c) {
  my $name = is_alphanum($c->param('name')) // return $c->render('search');
  my $data = page('Search')->load($name);

  if (@{$data->{authors}} == 1 && !@{$data->{dists}}) {
    $c->redirect_to('/author/'.$data->{authors}[0]);
    return;
  }
  if (@{$data->{dists}} == 1 && !@{$data->{authors}}) {
    $c->redirect_to('/dist/'.$data->{dists}[0]);
    return;
  }
  $c->stash(cpants => $data);
  $c->render('search');
}

1;
