package WWW::CPANTS::Web::Controller::Recent;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use parent 'Mojolicious::Controller';

sub index ($c) {
  my $page = $c->param('page') // 1;
  my $data = page('Recent')->load($page) or return $c->reply->not_found;
  my $format = $c->stash('format') // '';
  if ($format eq 'json') {
    return $c->render(json => $data->{data});
  }
  $c->stash(cpants => $data);
  $c->render('recent');
}

1;
