package WWW::CPANTS::API::Model::V5::Dist::Releases;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Format;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Util::Datetime;

with qw/WWW::CPANTS::Role::API::Model::V5::Dist::GetUid/;

sub path_template ($self) { '/dist/{name}/releases' }

sub operation ($self) {
    +{
        tags        => ['Distribution'],
        description => 'Returns past releases of the distribution',
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
                description => 'past releases of the distribution',
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

sub _load ($self, $params = {}) {
    my ($uid, $dist) = $self->get_uid($params);
    return unless $uid;

    my $length = is_int($params->{length}) // 50;
    my $start  = is_int($params->{start})  // 0;

    my $db       = $self->db;
    my $uids     = decode_json($dist->{uids} // '[]');
    my $total    = @$uids;
    my @releases = splice @$uids, $start, $length;

    my $kwalitee = $db->table('Kwalitee')->select_all_core_kwalitee_of([map { $_->{uid} } @releases]) // [];
    my %scores   = map { $_->{uid} => $_->{core_kwalitee} } @$kwalitee;

    my @rows;
    for my $release (@releases) {
        push @rows, {
            name         => $dist->{name},
            version      => $release->{version},
            date         => ymd($release->{released}),
            author       => $release->{author},
            availability => release_availability($release),
            score        => $scores{ $release->{uid} },
        };
    }
    return {
        recordsTotal => $total,
        data         => \@rows,
    };
}

1;
