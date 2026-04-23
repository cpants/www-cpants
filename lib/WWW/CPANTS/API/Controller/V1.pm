package WWW::CPANTS::API::Controller::V1;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS;
use Data::Dump qw(dump);
use WWW::CPANTS::API::Model::V1::Uploads;
use WWW::CPANTS::API::Model::V1::Kwalitee;

sub uploads ($c) {
    my $method = uc $c->req->method;
    my $params =
          $method eq 'GET'  ? $c->req->query_params->to_hash
        : $method eq 'POST' ? $c->req->body_params->to_hash
        :                     {};
    my $model = WWW::CPANTS::API::Model::V1::Uploads->new(ctx => $c->app->ctx);
    my ($res, $errors) = $model->load($params);
    if ($errors) {
        $c->stash(status => $errors->{status});
        return $c->render(
            json => +{
                errors => $errors->{errors},
                path   => $c->req->url->path_query,
            },
        );
    }
    if (!$res) {
        return $c->reply->not_found;
    }
    $c->render(json => $res);
}

sub kwalitee ($c) {
    my $method = uc $c->req->method;
    my $model = WWW::CPANTS::API::Model::V1::Kwalitee->new(ctx => $c->app->ctx);
    my ($res, $errors) = $model->load({ pause_id => $c->stash('pause_id') });
    if ($errors) {
        $c->stash(status => $errors->{status});
        return $c->render(
            json => +{
                errors => $errors->{errors},
                path   => $c->req->url->path_query,
            },
        );
    }
    if (!$res) {
        return $c->reply->not_found;
    }
    $c->render(json => $res);
}

1;
