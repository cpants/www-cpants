package WWW::CPANTS::Web::Controller::Root;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use parent 'Mojolicious::Controller';

sub check_maintenance ($c) {
    if (under_maintenance()) {
        $c->stash("cpants.has_notice"         => 1);
        $c->stash("cpants.notice_maintenance" => 1);
    }
    if (under_analysis()) {
        $c->stash("cpants.has_notice"       => 1);
        $c->stash("cpants.notice_analyzing" => 1);
    }
    return 1;
}

1;
