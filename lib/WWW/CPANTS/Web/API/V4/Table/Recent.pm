package WWW::CPANTS::Web::API::V4::Table::Recent;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use WWW::CPANTS::Util::Kwalitee;
use parent 'WWW::CPANTS::Web::Data';

sub load ($self, $params = {}) {
    my $days   = is_int($params->{days})   // 357;
    my $length = is_int($params->{length}) // 25;
    my $start  = is_int($params->{start})  // 0;

    my $db       = $self->db;
    my $table    = $db->table('Uploads');
    my $releases = $table->select_all_recent_releases($days, $length, $start);
    my $total    = $table->count_recent_releases($days);

    my %scores = map { $_->{uid} => $_->{core_kwalitee} } @{ $db->table('Kwalitee')->select_all_core_kwalitee_of([map { $_->{uid} } @$releases]) // [] };

    my @rows;
    for my $release (@$releases) {
        $release->{$_} = html($release->{$_}) for keys %$release;
        push @rows, {
            name     => $release->{name},
            version  => $release->{version},
            pause_id => $release->{author},
            date     => ymd($release->{released}),
            score    => $scores{ $release->{uid} },
        };
    }
    return {
        recordsTotal => $total,
        data         => \@rows,
    };
}

1;
