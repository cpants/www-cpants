package WWW::CPANTS::API::Model::V5;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use constant api_info => +{
    title       => 'CPANTS API',
    version     => '5.0',
    description => 'This API is mostly used internally to build the [CPANTS](https://cpants.cpanauthors.org/) web frontend.',
};

with qw/WWW::CPANTS::Role::OpenApiSchemaBuilder/;

1;
