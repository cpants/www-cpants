package WWW::CPANTS::API::Model::V4::Table::FailsIn;

use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Format;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Util::Datetime;

sub operation ($self) {
    +{
        tags        => ['DataTables'],
        description => 'Returns releases that fail a specific metric',
        deprecated  => json_true,
        parameters  => [{
                description => 'metric name',
                in          => 'query',
                name        => 'name',
                required    => json_true,
                schema      => {
                    type    => 'string',
                    enum    => [sort($self->ctx->kwalitee->names->@*)],
                    default => 'extractable',
                },
            },
            {
                description => 'latest/cpan/backpan',
                in          => 'query',
                name        => 'type',
                schema      => {
                    type    => 'string',
                    enum    => [qw/latest cpan backpan/],
                    default => 'latest',
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
                description => 'releases that fail a specific metric',
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
                                            availability => { type => 'string' },
                                        },
                                    },
                                },
                                indicator => {
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

sub _load ($self, $params = {}) {
    my $name = $self->ctx->kwalitee->is_valid_name($params->{name})
        or return $self->bad_request("'$params->{name}' is not a valid indicator name");

    my $type = is_availability_type($params->{type} // 'latest')
        or return $self->bad_request("'$params->{type}' seems not a valid type");

    my $length = is_int($params->{length}) // 50;
    my $start  = is_int($params->{start})  // 0;

    my $db       = $self->db;
    my $table    = $db->table('Kwalitee');
    my $uids     = $table->fails_in($name, $type, $length, $start);
    my $total    = $table->count_fails_in($name, $type);
    my %releases = map { $_->{uid} => $_ } @{ $db->table('Uploads')->select_all_by_uids($uids) // [] };

    my @rows;
    for my $uid (@$uids) {
        my $release = $releases{$uid};
        if (!$release) {
            $self->log(info => "$uid is not found in uploads");
            next;
        }
        my $name_version = $release->{name} . (defined $release->{version} ? '-' . $release->{version} : '');
        push @rows, {
            name_version => $name_version,
            author       => $release->{author},
            date         => ymd($release->{released}),
            availability => release_availability($release),
        };
    }

    my $data = slurp_json("kwalitee/$name");

    return {
        recordsTotal => $total,
        data         => \@rows,
        indicator    => $data->{indicator},
    };
}

1;
