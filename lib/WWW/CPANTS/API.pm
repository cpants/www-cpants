package WWW::CPANTS::API;

use Mojo::Base 'Mojolicious', -signatures;
use Digest::MD5 qw/md5_hex/;
use WWW::CPANTS::Util::Loader;
use WWW::CPANTS::API::Context;
use String::CamelCase qw/camelize/;
use Mock::MonkeyPatch;
use JSON::Validator;
use JSON::Validator::Schema::OpenAPIv3;

has 'ctx' => \&_build_ctx;

sub startup ($app) {
    if ($ENV{CPANTS_API_DEBUG} or $^O eq 'MSWin32') {
        $app->mode('development');
        $app->log->level('debug');
    } else {
        $app->mode('production');
        $app->log->level('error');
    }
    $app->secrets([md5_hex($$ . time)]);

    $app->{mock} = Mock::MonkeyPatch->patch(
        'JSON::Validator::Schema::OpenAPIv3::base_url' => sub ($self, $url = undef) {
            # No need to modify on the fly
            return Mojo::URL->new($self->get('/servers/0/url') || '');
        },
    );

    my $r = $app->routes->under('/')->to('root#check_maintenance');

    for my $path (qw/v5 v4 acme/) {
        my %conf = (
            schema => 'v3',
            url    => $app->build_openapi_schema($path),
            route  => $r->under("/$path")->to("open_api#$path"),
        );
        $conf{default_response_code} = [];
        $app->plugin(OpenAPI => \%conf);
    }

    $r->get('/')->to('open_api#root');

    $app->plugin('WWW::CPANTS::API::Plugin::DoesAccept');
}

sub _build_ctx ($self) {
    WWW::CPANTS::API::Context->new;
}

sub build_openapi_schema ($self, $path) {
    my $name  = ucfirst($path);
    my $class = "WWW::CPANTS::API::Model::$name";
    use_module($class)->build_schema($self->ctx);
}

1;
