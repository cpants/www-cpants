package WWW::CPANTS::API::Model::V4;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use constant api_info => +{
    title       => 'CPANTS API',
    version     => '4.0; deprecated',
    description => 'This API is mostly used internally to build the older version of [CPANTS](https://cpants.cpanauthors.org/) web frontend.',
};

with qw/WWW::CPANTS::Role::OpenApiSchemaBuilder/;

1;
