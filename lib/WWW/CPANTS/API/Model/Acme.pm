package WWW::CPANTS::API::Model::Acme;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use constant api_info => +{
    title       => 'Acme::CPANAuthors API',
    version     => '1.0',
    description => 'This API is mostly used internally to build the [Acme::CPANAuthors](https://acme.cpanauthors.org/) web frontend.',
};

with qw/WWW::CPANTS::Role::OpenApiSchemaBuilder/;

1;
