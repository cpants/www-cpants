package WWW::CPANTS::Web::Controller;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use WWW::CPANTS::Util::Loader;
use String::CamelCase qw/camelize decamelize/;
use Syntax::Keyword::Try;
use constant DEBUG => $ENV{CPANTS_WEB_DEBUG};

sub render_with ($c, $code) {
    my $params = $c->get_params;
    my $format = $c->stash('format') // '';
    my $res    = $code->($c, $params, $format);
    return $c->reply->not_found unless $res;

    if ($res->{json}) {
        return $c->render(json => $res->{json});
    } elsif ($res->{redirect_to}) {
        return $c->redirect_to($res->{redirect_to});
    } elsif ($res->{static}) {
        if (my $asset = $c->app->static->file($res->{static})) {
            $c->app->types->content_type($c, { file => $asset->path });
            if ($res->{mtime}) {
                require Mojo::Asset::Memory;
                $asset = Mojo::Asset::Memory->new->add_chunk($asset->slurp);
                $asset->mtime($res->{mtime});
            }
            return $c->reply->asset($asset);
        }
        return $c->reply->not_found;
    }
    $c->stash(cpants => $res->{stash}) if $res->{stash};

    my $render = $res->{render};
    return $c->render(ref $render eq 'HASH' ? %$render : $render);
}

sub get_params ($c) {
    my $method = uc $c->req->method;
    my $params =
          $method eq 'GET'  ? $c->req->query_params->to_hash
        : $method eq 'POST' ? $c->req->body_params->to_hash
        :                     {};
    if (my $match = $c->match->stack->[-1]) {
        $params->{$_} = $match->{$_} for keys %$match;
    }
    $params;
}

sub get_api ($c, $name, $params = {}) {
    my $class = "WWW::CPANTS::API::Model::V5::$name";
    my $model = eval { use_module($class) } or return;
    if (DEBUG) { warn "GOING TO CALL $name"; }
    try {
        my ($res, $errors) = $model->new(ctx => $c->app->ctx->api_ctx)->load($params);
        if ($errors) {
            warn("API ERROR: $name: " . Data::Dump::dump($errors));
            return;
        }
        if (DEBUG) {
            warn("API: $name: " . Data::Dump::dump($res));
        }
        return $res // {};
    } catch {
        Carp::carp $@; return
    }
}

sub tab_class ($c, $parent, $name = undef) {
    return $parent unless defined $name and $name ne '';
    join '::', $parent, (length $name < 3 ? uc $name : camelize($name));
}

sub template_name ($self, $tabclass) {
    decamelize($tabclass =~ s|::|/|gr);
}

1;
