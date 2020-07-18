package WWW::CPANTS::Web::API::V4::Table::CPANDistributionsBy;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use WWW::CPANTS::Util::Kwalitee;
use parent 'WWW::CPANTS::Web::Data';

sub load ($self, $params = {}) {
    my $pause_id = is_pause_id(uc $params->{pause_id}) or return $self->error;

    my $length = is_int($params->{length}) // 50;
    my $start  = is_int($params->{start})  // 0;

    my $db            = $self->db;
    my $uploads_table = $db->table('Uploads');
    my $releases      = $uploads_table->select_all_cpan_distributions_by($pause_id, $length, $start);
    my $total         = $uploads_table->count_cpan_distributions_by($pause_id);

    my @uids = map { $_->{uid} } @$releases;

    my $kwalitee_table = $db->table('Kwalitee');
    my %kwalitee       = map { delete $_->{uid} => $_ } @{ $kwalitee_table->find_all(\@uids) // [] };

    $_->{kwalitee} = $kwalitee{ $_->{uid} } for @$releases;

    my @rows;
    for my $release (@$releases) {
        $release->{$_} = html($release->{$_}) for keys %$release;
        push @rows, {
            name    => $release->{name},
            version => $release->{version},
            latest  => $release->{latest},
            date    => ymd($release->{released}),
            score   => $release->{kwalitee}{core_kwalitee},
            fails   => [map { $_->{name} } grep { !$_->{is_extra} && !$_->{is_experimental} && !$release->{kwalitee}{ $_->{name} } && defined $release->{kwalitee}{ $_->{name} } } @{ kwalitee_indicators() }],
        };
    }
    return {
        recordsTotal => $total,
        data         => \@rows,
    };
}

1;
