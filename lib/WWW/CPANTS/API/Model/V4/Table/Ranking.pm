package WWW::CPANTS::API::Model::V4::Table::Ranking;

use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Util::JSON;

sub operation ($self) {
    +{
        tags        => ['DataTables'],
        description => 'Returns top-ranking authors',
        deprecated  => json_true,
        parameters  => [{
                description => 'five_or_more/less_than_five',
                in          => 'query',
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
                                        type => 'object',
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
    my $league = $params->{league} // '';
    my $method = $Methods{$league}
        or return $self->bad_request("'$league' is not a valid league");

    my $select_method = $method->{select};
    my $count_method  = $method->{count};

    my $length = is_int($params->{length}) // 50;
    my $start  = is_int($params->{start})  // 0;

    my $db      = $self->db;
    my $table   = $db->table('Authors');
    my $ranking = $table->$select_method($length, $start);
    my $total   = $table->$count_method();

    my @rows;
    for my $author (@$ranking) {
        push @rows, $author;
    }
    return {
        recordsTotal => $total,
        data         => \@rows,
    };
}

1;
