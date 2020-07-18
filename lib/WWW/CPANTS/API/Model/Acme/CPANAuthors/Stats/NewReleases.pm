package WWW::CPANTS::API::Model::Acme::CPANAuthors::Stats::NewReleases;

use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS;

sub path_template ($self) { '/cpan_authors/{module_id}/stats/new_releases' }

sub operation ($self) {
    +{
        description => 'Returns a list of Acme::CPANAuthors modules',
        parameters  => [{
            description => 'Module ID',
            in          => 'path',
            name        => 'module_id',
            required    => json_true,
            schema      => { type => 'string' },
        }],
        responses => {
            200 => {
                description => 'Yearly new releases',
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
                                            year     => { type => 'integer' },
                                            releases => { type => 'integer' },
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

sub _load ($self, $params = []) {
    my $stats_table = $self->db->table('AcmeStats');
    my $rows        = $stats_table->select_new_releases_by_module_id($params->{module_id});

    return {
        recordsTotal => scalar @$rows,
        data         => $rows,
    };
}

1;
