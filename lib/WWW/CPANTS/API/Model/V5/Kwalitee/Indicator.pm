package WWW::CPANTS::API::Model::V5::Kwalitee::Indicator;

use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::Util::JSON;

sub path_template ($self) { '/kwalitee/{name}' }

sub operation ($self) {
    +{
        tags        => ['Kwalitee'],
        description => 'Returns Kwalitee metrics',
        parameters  => [{
                description => 'kwalitee indicator name',
                in          => 'path',
                name        => 'name',
                required    => json_true,
                schema      => { type => 'string' },
            },
        ],
        responses => {
            200 => {
                description => 'Kwalitee metrics',
                content     => {
                    'application/json' => {
                        schema => {
                            type       => 'object',
                            properties => {
                                total_failing_latest_releases => { type => 'integer' },
                                data                          => {
                                    type       => 'object',
                                    properties => {
                                        indicator => {
                                            type       => 'object',
                                            properties => {
                                                name        => { type => 'string' },
                                                description => { type => 'string' },
                                                remedy      => { type => 'string' },
                                                defined_in  => { type => 'string' },
                                                level       => { type => 'string' },
                                            },
                                        },
                                        stats                   => { type => 'object' },
                                        failing_latest_releases => {
                                            type  => 'array',
                                            items => { type => 'object' },
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
    my $name = $params->{name} // '';
    return $self->bad_request("$name is not a valid indicator name") unless $self->ctx->kwalitee->is_valid_name($name);

    my $data  = slurp_json("kwalitee/$name");
    my $total = delete $data->{total_failing_latest_releases};
    return {
        data                          => $data,
        total_failing_latest_releases => $total,
    };
}

sub save ($self) {
    my $db       = $self->db;
    my $kwalitee = $db->table('Kwalitee');
    for my $indicator ($self->ctx->kwalitee->indicators->@*) {
        my $name = $indicator->{name};
        $self->log(info => "creating page for $name");

        my $stats = $kwalitee->yearly_stats_for($name);

        my $fails = $self->model('V5::Kwalitee::Fail')->load({
            name => $name,
            type => 'latest',
        });

        my $level =
             !$indicator->{is_extra} && !$indicator->{is_experimental} ? 'core'
            : $indicator->{is_extra}                                   ? 'extra'
            : $indicator->{is_experimental}                            ? 'experimental'
            :                                                            '';

        my %data = (
            indicator => {
                name        => $name,
                description => $indicator->{error},
                remedy      => $indicator->{remedy},
                defined_in  => $indicator->{defined_in},
                level       => $level,
            },
            stats                         => $stats,
            failing_latest_releases       => $fails->{data},
            total_failing_latest_releases => $fails->{recordsTotal},
        );

        save_json("kwalitee/$name", \%data);
    }
}

1;
