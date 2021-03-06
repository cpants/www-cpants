package WWW::CPANTS::API::Model::V4::Table::CPANDistributionsBy;

use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Util::Datetime;

sub operation ($self) {
    +{
        tags        => ['DataTables'],
        description => 'Returns CPAN Distributions released by the author',
        deprecated  => json_true,
        parameters  => [{
                description => 'PAUSE ID',
                in          => 'query',
                name        => 'pause_id',
                required    => json_true,
                schema      => { type => 'string' },
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
                description => 'CPAN Distributions released by the author',
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
                                            latest  => { type => 'integer' },
                                            date    => {
                                                type   => 'string',
                                                format => 'date',
                                            },
                                            score => {
                                                type   => 'number',
                                                format => 'float',
                                            },
                                            fails => {
                                                type  => 'array',
                                                items => { type => 'string' },
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
    my $pause_id = is_pause_id($params->{pause_id})
        or return $self->bad_request("'$params->{pause_id}' is not a valid pause id");

    my $length = is_int($params->{length}) // 50;
    my $start  = is_int($params->{start})  // 0;

    my $db            = $self->db;
    my $uploads_table = $db->table('Uploads');
    my $releases      = $uploads_table->select_all_cpan_distributions_by($pause_id, $length, $start);
    my $total         = $uploads_table->count_cpan_distributions_by($pause_id);

    my @uids = map { $_->{uid} } @$releases;

    my $kwalitee_table = $db->table('Kwalitee');
    my %kwalitee       = map { delete $_->{uid} => $_ } @{ $kwalitee_table->find_all(\@uids) // [] };

    $_->{kwalitee} = $kwalitee{ $_->{uid} } for @$releases;

    my @core_metrics = $self->ctx->kwalitee->core_metrics->@*;

    my @rows;
    for my $release (@$releases) {
        push @rows, {
            name    => $release->{name},
            version => $release->{version},
            latest  => $release->{latest},
            date    => ymd($release->{released}),
            score   => $release->{kwalitee}{core_kwalitee},
            fails   => [grep { !$release->{kwalitee}{$_} && defined $release->{kwalitee}{$_} } @core_metrics],
        };
    }
    return {
        recordsTotal => $total,
        data         => \@rows,
    };
}

1;
