package WWW::CPANTS::Web::Page::Kwalitee::Indicator;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use WWW::CPANTS::Util::Kwalitee;
use parent 'WWW::CPANTS::Web::Data';

sub load ($self, $name = '', @args) {
    return unless is_kwalitee_metric($name);

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
    for my $indicator (@{ kwalitee_indicators() }) {
        my $name = $indicator->{name};
        log(info => "creating page for $name");

        my $stats = $kwalitee->yearly_stats_for($name);

        my $fails = api4('Table::FailsIn')->load({
            name => $name,
            type => 'latest',
        });

        my $level =
             !$indicator->{is_extra} && !$indicator->{is_experimental} ? 'core'
            : $indicator->{is_extra}        ? 'extra'
            : $indicator->{is_experimental} ? 'experimental'
            :                                 '';

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
