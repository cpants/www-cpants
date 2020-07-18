package WWW::CPANTS::API::Model::V4::Search;

use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS;

sub request_method ($self) { 'post' }

sub operation ($self) {
    +{
        tags        => ['Search'],
        description => 'Returns names of matched CPAN Authors/Distributions',
        deprecated  => json_true,
        requestBody => {
            content => {
                'application/x-www-form-urlencoded' => {
                    schema => {
                        type       => 'object',
                        properties => {
                            name => {
                                description => '(part of) a PAUSE ID or a distribution name',
                                type        => 'string',
                            },
                        },
                        required => ['name'],
                    },
                },
            },
        },
        responses => {
            200 => {
                description => 'names of matched CPAN Authors/Distributions',
                content     => {
                    'application/json' => {
                        schema => {
                            type       => 'object',
                            properties => {
                                authors => {
                                    type  => 'array',
                                    items => { type => 'string' },
                                },
                                dists => {
                                    type  => 'array',
                                    items => { type => 'string' },
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
    my $name = is_alphanum($params->{name}) or return {
        authors => [],
        dists   => [],
    };

    my $db   = $self->db;
    my $rows = $db->table('Uploads')->search_for($name);

    my (@authors, @dists);
    for my $row (@$rows) {
        if ($row->{author}) {
            push @authors, $row->{author};
        }
        if ($row->{name}) {
            push @dists, $row->{name};
        }
    }

    return {
        authors => \@authors,
        dists   => \@dists,
    };
}

1;
