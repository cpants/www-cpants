package WWW::CPANTS::Web::Controller::Home;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use parent 'Mojolicious::Controller';

sub index ($c) {
  my $data = page('Home')->load; # or return $c->reply->not_found;
  $c->stash(cpants => $data);
  $c->render('home');
}

1;
