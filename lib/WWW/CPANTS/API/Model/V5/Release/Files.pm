package WWW::CPANTS::API::Model::V5::Release::Files;

use Mojo::Base 'WWW::CPANTS::API::Model::V5::Dist::Files', -signatures;
use WWW::CPANTS::Util::JSON;

sub path_template ($self) { '/release/{pause_id}/{name}/files' }

sub operation ($self) {
    +{
        tags        => ['Release'],
        description => 'Returns files in the release',
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
                description => 'files in the release',
                content     => {
                    'application/json' => {
                        schema => {
                            type       => 'object',
                            properties => {
                                data => {
                                    type => 'object',
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
