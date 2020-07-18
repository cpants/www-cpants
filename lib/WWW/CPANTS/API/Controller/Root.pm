package WWW::CPANTS::API::Controller::Root;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS;

sub check_maintenance ($c) {
    if (WWW::CPANTS->instance->is_under_maintenance) {
        $c->stash("cpants.has_notice"         => 1);
        $c->stash("cpants.notice_maintenance" => 1);
    }
    my $json = slurp_json('Task::AnalyzeAll');
    $c->stash('last_analyzed', $json->{last_executed});
    return 1;
}

1;
