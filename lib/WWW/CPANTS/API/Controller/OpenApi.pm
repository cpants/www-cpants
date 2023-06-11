package WWW::CPANTS::API::Controller::OpenApi;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use constant DEBUG => !!$ENV{CPANTS_API_DEBUG};

sub root ($c) {
    $c->redirect_to('/v5');
}

sub _fix ($path) { $path =~ s!^/!!r }

sub acme ($c) {
    $c->stash(cpants_api_version => 'acme');
    if (_fix($c->req->url->path) eq 'acme' and !$c->does_accept('application/json')) {
        $c->stash(format => 'html');
    } else {
        $c->stash(format  => 'json');
        $c->stash(handler => 'openapi');
    }
    return 1;
}

sub v4 ($c) {
    $c->stash(cpants_api_version => 'v4');
    if (_fix($c->req->url->path) eq 'v4' and !$c->does_accept('application/json')) {
        $c->stash(format => 'html');
    } else {
        $c->stash(format  => 'json');
        $c->stash(handler => 'openapi');
    }
    return 1;
}

sub v5 ($c) {
    $c->stash(cpants_api_version => 'v5');
    if (_fix($c->req->url->path) eq 'v5' and !$c->does_accept('application/json')) {
        $c->stash(format => 'html');
    } else {
        $c->stash(format  => 'json');
        $c->stash(handler => 'openapi');
    }
    return 1;
}

sub dispatch ($c) {
    $c->openapi->valid_input or return;

    my $method = uc $c->req->method;
    my $params =
          $method eq 'GET'  ? $c->req->query_params->to_hash
        : $method eq 'POST' ? $c->req->body_params->to_hash
        :                     {};
    if (my $match = $c->match->stack->[-1]) {
        $params->{$_} = $match->{$_} for keys %$match;
    }

    if (DEBUG) {
        my $dump = Data::Dump::dump({
            map { $_ => $params->{$_} }
            grep !/openapi/, keys %$params
        });
        $c->app->log->debug("PARAMS for $c: $dump");
    }

    my $module = $c->stash('module') or return;
    my $model  = $module->new(ctx => $c->app->ctx);
    my ($res, $errors) = $model->load($params, 'validated');

    if ($errors) {
        $c->stash(status => $errors->{status});
        return $c->render(
            openapi => +{
                errors => $errors->{errors},
                path   => $c->req->url->path_query,
            },
        );
    }
    if (!$res) {
        return $c->reply->not_found;
    }

    if (defined $params->{draw}) {    # for jQuery.DataTables
        $res->{draw} = $params->{draw};
        $res->{recordsFiltered} //= $res->{recordsTotal};
    }

    if (DEBUG) {
        $c->app->log->debug("DATA for $c: " . Data::Dump::dump($res));
    }

    $c->res->headers->access_control_allow_origin('*');
    return $c->render(openapi => $res);
}

1;
