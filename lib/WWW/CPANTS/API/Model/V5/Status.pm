package WWW::CPANTS::API::Model::V5::Status;

use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Util::JSON;

sub operation ($self) {
    +{
        tags        => ['Status'],
        description => 'Returns CPANTS status',
        parameters  => [],
        responses   => {
            200 => {
                description => 'CPANTS status',
                content     => {
                    'application/json' => {
                        schema => {
                            type       => 'object',
                            properties => {
                                maintenance   => { type => 'integer' },
                                last_analyzed => {
                                    description => 'Epoch time',
                                    type        => 'integer',
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
    my $maintenance = WWW::CPANTS->instance->is_under_maintenance;

    my $json          = slurp_json('Task::AnalyzeAll');
    my $last_analyzed = $json->{last_executed};

    return {
        maintenance   => $maintenance,
        last_analyzed => $last_analyzed,
    };
}

1;
