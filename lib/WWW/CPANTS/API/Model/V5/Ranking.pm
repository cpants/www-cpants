package WWW::CPANTS::API::Model::V5::Ranking;

use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Util::Datetime;
use WWW::CPANTS::Util::JSON;

sub path_template ($self) { '/ranking/{league}' }

sub operation ($self) {
    +{
        tags        => ['Ranking'],
        description => 'Returns top-ranking authors',
        parameters  => [{
                description => 'five_or_more/less_than_five',
                in          => 'path',
                name        => 'league',
                required    => json_true,
                schema      => {
                    type => 'string',
                    enum => [qw/five_or_more less_than_five/],
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
                description => 'top-ranking authors',
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
                                            rank     => { type => 'integer' },
                                            pause_id => { type => 'string' },
                                            average_core_kwalitee => {
                                                type   => 'number',
                                                format => 'float',
                                            },
                                            cpan_dists      => { type => 'integer' },
                                            last_release_on => {
                                                type   => 'string',
                                                format => 'date',
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

my %Methods = (
    five_or_more => {
        select => 'select_ranking_five_or_more',
        count  => 'count_authors_with_five_or_more_distributions',
    },
    less_than_five => {
        select => 'select_ranking_less_than_five',
        count  => 'count_authors_with_less_than_five_distributions',
    },
);

sub _load ($self, $params = {}) {
    my $league        = $params->{league} // '';
    my $methods       = $Methods{$league} or return $self->bad_request("'$league' is not a valid league");
    my $select_method = $methods->{select};
    my $count_method  = $methods->{count};

    my $length = is_int($params->{length}) // 50;
    my $start  = is_int($params->{start})  // 0;

    my $db      = $self->db;
    my $table   = $db->table('Authors');
    my $ranking = $table->$select_method($length, $start);
    my $total   = $table->$count_method();

    my @rows;
    for my $author (@$ranking) {
        push @rows, {
            rank                  => $author->{rank},
            pause_id              => $author->{pause_id},
            average_core_kwalitee => $author->{average_core_kwalitee},
            cpan_dists            => $author->{cpan_dists},
            last_release_on       => ymd($author->{last_release_at}),
        };
    }
    return {
        recordsTotal => $total,
        data         => \@rows,
    };
}

1;
