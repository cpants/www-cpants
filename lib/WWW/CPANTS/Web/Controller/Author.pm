package WWW::CPANTS::Web::Controller::Author;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use WWW::CPANTS::Web::Util::Badge;
use parent 'Mojolicious::Controller';

sub index ($c) {
  my $id = uc $c->param('id');
  my $data = page('Author')->load($id) or return $c->reply->not_found;

  my $format = $c->stash('format') // '';
  if ($format eq 'json') {
    return $c->render(json => $data->{data});
  }
  if ($format eq 'png') {
    my $path = WWW::CPANTS::Web::Util::Badge->new($data->{data}{author}{average_core_kwalitee})->path;
    return $c->reply->static($path);
  }

  $c->stash(cpants => $data);
  $c->stash(body_class => "pause-".(lc $id));
  $c->render('author');
}

sub feed ($c) {
  my $id = uc $c->param('id');
  my $data = page('Author::Feed')->load($id) or return $c->reply->not_found;
  $c->render(format => 'atom', text => $data);
}

1;
