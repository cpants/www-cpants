package WWW::CPANTS::Web::Controller::Api;

use WWW::CPANTS;
use parent 'Mojolicious::Controller';

sub check_xhr ($c) {
  unless ($c->req->is_xhr) {
    # warn "NO XHR?";
    return;
  }
  $c->stash(format => 'json');
  return 1;
}

1;
