package WWW::CPANTS::API::Model::V5::Dist::UsedBy;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::Util::Datetime;
use WWW::CPANTS::Util::JSON;

with qw/WWW::CPANTS::Role::API::Model::V5::Dist::GetUid/;

sub path_template ($self) { '/dist/{name}/used_by' }

sub operation ($self) {
    +{
        tags        => ['Distribution'],
        description => 'Returns CPAN distributions that depend on the distribution',
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
                description => 'CPAN distributions that depend on the distribution',
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

sub _load ($self, $params = {}) {
    my ($uid, $dist) = $self->get_uid($params);
    return unless $uid;

    my $length = is_int($params->{length}) // 50;
    my $start  = is_int($params->{start})  // 0;

    my @used_by = @{ decode_json($dist->{used_by} // '[]') };
    my $total   = @used_by;

    my $db    = $self->db;
    my @names = map { $_->[0] } splice @used_by, $start, $length;
    my @uids  = map { $_->{latest_dev_uid} // $_->{latest_stable_uid} } @{ $db->table('Distributions')->select_all_latest_uids_by_name(\@names) // [] };
    my %score = map { $_->{uid} => $_->{core_kwalitee} } @{ $db->table('Kwalitee')->select_all_core_kwalitee_of(\@uids) // [] };
    my @dists = map {
        +{
            name_version => $_->{name} . '-' . $_->{version},
            author       => $_->{author},
            date         => ymd($_->{released}),
            score        => $score{ $_->{uid} },
        }
    } sort { $b->{released} <=> $a->{released} } @{ $db->table('Uploads')->select_all_by_uids(\@uids) // [] };
    return {
        recordsTotal => $total,
        data         => \@dists,
    };
}

1;
