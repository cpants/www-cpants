package WWW::CPANTS::API::Model::V5::Dist::Metadata;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Util::JSON;

with qw/WWW::CPANTS::Role::API::Model::V5::Dist::GetUid/;

sub path_template ($self) { '/dist/{name}/metadata' }

sub operation ($self) {
    +{
        tags        => ['Distribution'],
        description => 'Returns metadata of the distribution',
        parameters  => [{
                description          => 'name of the distribution',
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
                description => 'metadata of the distribution',
                content     => {
                    'application/json' => {
                        schema => {
                            type       => 'object',
                            properties => {
                                data => {
                                    type       => 'object',
                                    properties => {
                                        metadata => { type => 'string' },
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

sub _load ($self, $params = {}) {
    my $uid = $self->get_uid($params);
    return unless $uid;

    my $json = $self->db->table('Analysis')->select_json_by_uid($uid);

    return {
        data => {
            metadata => $json // '{}',
        },
    };
}

1;
