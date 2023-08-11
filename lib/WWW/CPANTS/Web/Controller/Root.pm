package WWW::CPANTS::Web::Controller::Root;

use Mojo::Base 'WWW::CPANTS::Web::Controller', -signatures;

sub check_maintenance ($c) {
    my $status = $c->get_api('Status') // {};

    if ($status->{maintenance}) {
        $c->stash("cpants.has_notice"         => 1);
        $c->stash("cpants.notice_maintenance" => 1);
    }
    $c->stash('last_analyzed', $status->{last_analyzed});
    $c->stash('tracking_id', WWW::CPANTS->instance->config->{tracking_id});
    return 1;
}

1;
