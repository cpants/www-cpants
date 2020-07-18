package WWW::CPANTS::API::Model::V4::Table::ReverseDependenciesOf;

use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Util::Datetime;
use WWW::CPANTS::Util::JSON;

sub operation ($self) {
    +{
        tags        => ['DataTables'],
        description => 'Returns CPAN distributions that depend on the distribution',
        deprecated  => json_true,
        parameters  => [{
                description => 'CPAN distribution',
                in          => 'query',
                name        => 'name',
                required    => json_true,
                schema      => {
                    type => 'string',
                },
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
    my $name = is_dist($params->{name})
        or return $self->bad_request("'$params->{name}' seems not a valid path");

    my $length = is_int($params->{length}) // 50;
    my $start  = is_int($params->{start})  // 0;

    my $db      = $self->db;
    my $dist    = $db->table('Distributions')->select_by_name($name) or return $self->bad_request(info => "$name not found");
    my @used_by = @{ decode_json($dist->{used_by} // '[]') };
    my $total   = @used_by;

    my @names = map { $_->[0] } splice @used_by, $start, $length;

    my @uids = map { $_->{latest_dev_uid} // $_->{latest_stable_uid} } @{ $db->table('Distributions')->select_all_latest_uids_by_name(\@names) // [] };

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
