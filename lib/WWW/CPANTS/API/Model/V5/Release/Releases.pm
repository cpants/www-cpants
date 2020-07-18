package WWW::CPANTS::API::Model::V5::Release::Releases;

use Mojo::Base 'WWW::CPANTS::API::Model::V5::Dist::Releases', -signatures;
use WWW::CPANTS::Util::JSON;

sub path_template ($self) { '/release/{pause_id}/{name}/releases' }

sub operation ($self) {
    +{
        tags        => ['Release'],
        description => 'Returns past releases of the release',
        parameters  => [{
                description => 'PAUSE ID',
                in          => 'path',
                name        => 'pause_id',
                required    => json_true,
                schema      => { type => 'string' },
            },
            {
                description          => 'name and version of the release',
                in                   => 'path',
                name                 => 'name',
                required             => json_true,
                schema               => { type => 'string' },
                'x-mojo-placeholder' => '#',
            },
            {
                description => 'number of records',
                in          => 'query',
                name        => 'length',
                schema      => {
                    type    => 'integer',
                    default => 50,
                },
            },
            {
                description => 'offset',
                in          => 'query',
                name        => 'start',
                schema      => {
                    type    => 'integer',
                    default => 0,
                },
            },
        ],
        responses => {
            200 => {
                description => 'past releases of the release',
                content     => {
                    'application/json' => {
                        schema => {
                            type       => 'object',
                            properties => {
                                recordsTotal => { type => 'integer' },
                                data         => {
                                    type  => 'array',
                                    items => {
                                        type       => 'object',
                                        properties => {
                                            name    => { type => 'string' },
                                            version => { type => 'string' },
                                            date    => {
                                                type   => 'string',
                                                format => 'date',
                                            },
                                            author       => { type => 'string' },
                                            availability => { type => 'string' },
                                            score        => {
                                                type   => 'number',
                                                format => 'float',
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
    };
}

1;
