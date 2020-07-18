package WWW::CPANTS::API::Model::V5::Kwalitee;

use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Format;
use WWW::CPANTS::Util::JSON;

sub path_template ($self) { '/kwalitee/' }

sub operation ($self) {
    +{
        tags        => ['Kwalitee'],
        description => 'Returns Kwalitee metrics information',
        parameters  => [],
        responses   => {
            200 => {
                description => 'Kwalitee metrics information',
                content     => {
                    'application/json' => {
                        schema => {
                            type       => 'object',
                            properties => {
                                data => {
                                    type       => 'object',
                                    properties => {
                                        core_indicators         => { type => 'object' },
                                        extra_indicators        => { type => 'object' },
                                        experimental_indicators => { type => 'object' },
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
    my $fails = $self->db->table('Kwalitee')->count_fails;

    my $indicators = $self->ctx->kwalitee->indicators;

    my %metrics;
    for my $indicator (@$indicators) {
        my $level =
              $indicator->{is_experimental} ? 'experimental'
            : $indicator->{is_extra}        ? 'extra'
            :                                 'core';
        my $name = $indicator->{name};
        push @{ $metrics{$level} //= [] }, {
            name              => $name,
            description       => $indicator->{error},
            remedy            => $indicator->{remedy},
            defined_in        => $indicator->{defined_in},
            latest_fails      => $fails->{"latest_$name"} // 0,
            cpan_fails        => $fails->{"cpan_$name"} // 0,
            backpan_fails     => $fails->{"backpan_$name"} // 0,
            latest_fail_rate  => percent($fails->{"latest_$name"} // 0, $fails->{latest_total}),
            cpan_fail_rate    => percent($fails->{"cpan_$name"} // 0, $fails->{cpan_total}),
            backpan_fail_rate => percent($fails->{"backpan_$name"} // 0, $fails->{backpan_total}),
        };
    }

    return {
        data => {
            core_indicators         => $metrics{core},
            extra_indicators        => $metrics{extra},
            experimental_indicators => $metrics{experimental},
        },
    };
}

sub _save ($self) {
    my $data = $self->_load;
    $data->{last_updated} = time;
    save_json($self->id, $data);
    return 1;
}

1;
