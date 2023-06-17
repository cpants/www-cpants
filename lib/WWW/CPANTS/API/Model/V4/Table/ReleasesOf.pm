package WWW::CPANTS::API::Model::V4::Table::ReleasesOf;

use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Format;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Util::Datetime;
use WWW::CPANTS::Util::JSON;

sub operation ($self) {
    +{
        tags        => ['DataTables'],
        description => 'Returns past releases of the distribution',
        deprecated  => json_true,
        parameters  => [{
                description => 'name of distribution',
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
    my $name = is_path($params->{name})
        or return $self->bad_request("'$params->{name}' seems not a valid path");

    my $length = is_int($params->{length}) // 50;
    my $start  = is_int($params->{start})  // 0;

    my $db       = $self->db;
    my $table    = $db->table('Distributions');
    my $dist     = $table->select_by_name($name);
    my $uids     = decode_json($dist->{uids}) // [];
    my $total    = @$uids;
    my @releases = splice @$uids, $start, $length;

    my $kwalitee = $db->table('Kwalitee')->select_all_core_kwalitee_of([map { $_->{uid} } @releases]) // [];

    my %scores = map { $_->{uid} => $_->{core_kwalitee} } @$kwalitee;

    my @rows;
    for my $release (@releases) {
        push @rows, {
            name         => $name,
            version      => $release->{version},
            date         => ymd($release->{released}),
            author       => $release->{author},
            availability => release_availability($release),
            score        => $scores{ $release->{uid} } // 0,
        };
    }
    return {
        recordsTotal => $total,
        data         => \@rows,
    };
}

1;
