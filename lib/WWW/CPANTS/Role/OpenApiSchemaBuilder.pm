package WWW::CPANTS::Role::OpenApiSchemaBuilder;

use Mojo::Base -role, -signatures;
use WWW::CPANTS::Util::Loader;
use experimental 'switch';

sub build_schema ($class, $ctx) {
    my $base_url = $ctx->api_base->clone;
    return +{
        openapi    => '3.0.0',
        info       => $class->api_info,
        servers    => [{ url => $base_url->path($class->_base_path)->to_string }],
        paths      => $class->_paths($ctx),
        components => {
            schemas => {
                DefaultResponse => $class->_default_response,
            },
        },
    };
}

sub _base_path ($class) {
    my ($path) = (lc $class) =~ /::(\w+)$/;
    return lc($path);
}

sub _paths ($class, $ctx) {
    my $models = submodules($class);

    my %paths;
    for my $name (keys %$models) {
        my $module    = use_module($models->{$name}) or next;
        my $model     = $module->new(ctx => $ctx);
        my $method    = $model->request_method;
        my $operation = $model->operation or next;
        $operation->{'x-mojo-to'} = [
            "open_api#dispatch",
            { module => $module },
        ];
        $paths{ $model->path_template }{$method} = $operation;
    }
    return \%paths;
}

sub _default_response ($class) {
    return +{
        type       => "object",
        required   => [qw/errors/],
        properties => {
            errors => {
                type  => "array",
                items => {
                    type       => "object",
                    required   => [qw/message/],
                    properties => {
                        message => { type => "string" },
                    },
                },
            },
            path => { type => "string" },
        },
    };
}

1;
