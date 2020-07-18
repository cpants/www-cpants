package WWW::CPANTS::API::Model::V5::Release::UsedBy;

use Mojo::Base 'WWW::CPANTS::API::Model::V5::Dist::UsedBy', -signatures;
use WWW::CPANTS::Util::JSON;

sub path_template ($self) { '/release/{pause_id}/{name}/used_by' }

sub operation ($self) {
    +{
        tags        => ['Release'],
        description => 'Returns CPAN distributions that depend on the release',
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
                description => 'CPAN distributions that depend on the release',
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
                                            name_version => { type => 'string' },
                                            author       => { type => 'string' },
                                            date         => {
                                                type   => 'string',
                                                format => 'date',
                                            },
                                            score => {
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
