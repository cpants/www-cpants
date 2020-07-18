package WWW::CPANTS::API::Model::V5::Author::RecentReleases;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Util::Datetime;

with qw/WWW::CPANTS::Role::API::Model::V5::Author::Status/;

sub path_template ($self) { '/author/{pause_id}/recent_releases' }

sub operation ($self) {
    +{
        tags        => ['Author'],
        description => 'Returns CPAN releases by the author',
        parameters  => [{
                description => 'PAUSE ID',
                in          => 'path',
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
                description => 'CPAN releases by the author',
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
        or return $self->bad_request(info => "'$params->{pause_id}' is not a valid pause id");

    my $length = is_int($params->{length}) // 50;
    my $start  = is_int($params->{start})  // 0;

    my ($status, $whois) = $self->check_whois_status($pause_id);
    return $whois unless $status;

    my $db            = $self->db;
    my $uploads_table = $db->table('Uploads');

    my $releases = $uploads_table->select_all_recent_releases_by($pause_id, $length, $start);
    my $total    = $uploads_table->count_recent_releases_by($pause_id);

    my @uids = map { $_->{uid} } @$releases;

    my $kwalitee_table = $db->table('Kwalitee');

    my %kwalitee = map { delete $_->{uid} => $_ } @{ $kwalitee_table->find_all(\@uids) // [] };

    $_->{kwalitee} = $kwalitee{ $_->{uid} } for @$releases;

    my @rows;
    for my $release (@$releases) {
        push @rows, {
            name    => $release->{name},
            version => $release->{version},
            date    => ymd($release->{released}),
            score   => $release->{kwalitee}{core_kwalitee},
            fails   => $self->ctx->kwalitee->failing_core_metrics($release->{kwalitee}),
        };
    }
    return {
        recordsTotal => $total,
        data         => \@rows,
    };
}

1;
