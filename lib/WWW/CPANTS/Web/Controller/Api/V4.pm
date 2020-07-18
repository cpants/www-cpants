package WWW::CPANTS::Web::Controller::Api::V4;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use parent 'Mojolicious::Controller';

sub search ($c) {
    my $params = $c->req->params->to_hash;
    my $data   = api4('Search')->load($params) or $c->reply->not_found;
    $c->render(json => $data);
}

sub recent_releases ($c) {
    my $params = $c->req->params->to_hash;
    my $data   = api4('Table::Recent')->load($params) or $c->reply->not_found;
    $data->{draw}            = is_int($params->{draw}) // 1;
    $data->{recordsFiltered} = $data->{recordsTotal};
    $c->render(json => $data);
}

sub recent_releases_by ($c) {
    my $params = $c->req->params->to_hash;
    my $data   = api4('Table::RecentBy')->load($params) or $c->reply->not_found;
    $data->{draw}            = is_int($params->{draw}) // 1;
    $data->{recordsFiltered} = $data->{recordsTotal};
    $c->render(json => $data);
}

sub cpan_distributions_by ($c) {
    my $params = $c->req->params->to_hash;
    my $data   = api4('Table::CPANDistributionsBy')->load($params) or $c->reply->not_found;
    $data->{draw}            = is_int($params->{draw}) // 1;
    $data->{recordsFiltered} = $data->{recordsTotal};
    $c->render(json => $data);
}

sub ranking ($c) {
    my $params = $c->req->params->to_hash;
    my $data   = api4('Table::Ranking')->load($params) or $c->reply->not_found;
    $data->{draw}            = is_int($params->{draw}) // 1;
    $data->{recordsFiltered} = $data->{recordsTotal};
    $c->render(json => $data);
}

sub fails_in ($c) {
    my $params = $c->req->params->to_hash;
    my $data   = api4('Table::FailsIn')->load($params) or $c->reply->not_found;
    $data->{draw}            = is_int($params->{draw}) // 1;
    $data->{recordsFiltered} = $data->{recordsTotal};
    $c->render(json => $data);
}

sub releases_of ($c) {
    my $params = $c->req->params->to_hash;
    my $data   = api4('Table::ReleasesOf')->load($params) or $c->reply->not_found;
    $data->{draw}            = is_int($params->{draw}) // 1;
    $data->{recordsFiltered} = $data->{recordsTotal};
    $c->render(json => $data);
}

sub reverse_dependencies_of ($c) {
    my $params = $c->req->params->to_hash;
    my $data   = api4('Table::ReverseDependenciesOf')->load($params) or $c->reply->not_found;
    $data->{draw}            = is_int($params->{draw}) // 1;
    $data->{recordsFiltered} = $data->{recordsTotal};
    $c->render(json => $data);
}

1;
