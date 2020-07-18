package WWW::CPANTS::API::Model::Acme::CPANAuthors::Modules;

use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::API::Util::Format;
use WWW::CPANTS::Util::Datetime;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS;

sub operation ($self) {
    +{
        description => 'Returns a list of Acme::CPANAuthors modules',
        parameters  => [],
        responses   => {
            200 => {
                description => 'A list of Acme::CPANAuthors modules with valid authors',
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
                                            name           => { type => 'string' },
                                            version        => { type => 'string' },
                                            released       => { type => 'string', format => 'date' },
                                            authors        => { type => 'integer' },
                                            new_authors    => { type => 'integer' },
                                            active_authors => {
                                                type        => 'integer',
                                                description => 'Authors who released anything in the year (or in the last 365 days)',
                                            },
                                            distributions         => { type => 'integer' },
                                            average_kwalitee      => { type => 'number', format => 'float' },
                                            average_core_kwalitee => { type => 'number', format => 'float' },
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
    my $modules_table = $self->db->table('AcmeModules');
    my $stats_table   = $self->db->table('AcmeStats');
    my $rows          = $modules_table->select_modules;
    my $stats         = $stats_table->select_latest_stats;
    my %map           = map { $_->{module_id} => $_ } @$stats;
    for my $row (@$rows) {
        my $stats_for_module = $map{ $row->{module_id} };
        for my $key (keys %$stats_for_module) {
            my $value = $stats_for_module->{$key};
            $value = kwalitee_score($value) if $key =~ /kwalitee/;
            $row->{$key} = $value;
        }
        $row->{released} = ymd($row->{released});
        $row->{id}       = delete $row->{module_id};
        $row->{name}     = delete $row->{module};
    }

    return {
        recordsTotal => scalar @$rows,
        data         => $rows,
    };
}

1;
