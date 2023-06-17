package WWW::CPANTS::API::Model::V5::Recent;

use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Util::Datetime;
use WWW::CPANTS::Util::JSON;

sub operation ($self) {
    +{
        tags        => ['Distribution'],
        description => 'Returns recent CPAN releases',
        parameters  => [{
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
                description => 'recent CPAN releases',
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
                                            name     => { type => 'string' },
                                            version  => { type => 'string' },
                                            pause_id => { type => 'string' },
                                            date     => {
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
    my $length = is_int($params->{length}) // 50;
    my $start  = is_int($params->{start})  // 0;

    my $db       = $self->db;
    my $table    = $db->table('Uploads');
    my $releases = $table->select_all_recent_releases($length, $start);
    my $total    = $table->count_recent_releases();

    my %scores = map { $_->{uid} => $_->{core_kwalitee} } @{ $db->table('Kwalitee')->select_all_core_kwalitee_of([map { $_->{uid} } @$releases]) // [] };

    my @rows;
    for my $release (@$releases) {
        push @rows, {
            name     => $release->{name},
            version  => $release->{version},
            pause_id => $release->{author},
            date     => ymd($release->{released}),
            score    => $scores{ $release->{uid} } // 0,
        };
    }
    return {
        recordsTotal => $total,
        data         => \@rows,
    };
}

1;
