package WWW::CPANTS::Bin::Task::UpdateRanking;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use WWW::CPANTS::Util::Kwalitee;
use parent 'WWW::CPANTS::Bin::Task';

sub run ($self, @args) {
    my $db      = $self->db;
    my $authors = $db->table('Authors');

    $self->update_ranking($authors->select_all_pause_ids_with_many_cpan_dists);
    $self->update_ranking($authors->select_all_pause_ids_with_few_cpan_dists);
}

sub update_ranking ($self, $pause_ids) {
    my $db       = $self->db;
    my $kwalitee = $db->table('Kwalitee');
    my $authors  = $db->table('Authors');
    my %ranking;
    my %score;
    for my $pause_id (@$pause_ids) {
        my ($kwalitee_sum, $core_kwalitee_sum, $total) = (0, 0, 0);
        for my $row (@{ $kwalitee->select_all_scores_for_author($pause_id) // [] }) {
            next if !$row->{kwalitee} && !$row->{core_kwalitee};
            $kwalitee_sum      += $row->{kwalitee};
            $core_kwalitee_sum += $row->{core_kwalitee};
            $total++;
        }
        $score{$pause_id}{average_kwalitee}      = $total ? kwalitee_score($kwalitee_sum / $total)      : 0;
        $score{$pause_id}{average_core_kwalitee} = $total ? kwalitee_score($core_kwalitee_sum / $total) : 0;
    }
    my ($rank, $ct, $current) = (0, 0, undef);
    for my $pause_id (sort { $score{$b}{average_core_kwalitee} <=> $score{$a}{average_core_kwalitee} } @$pause_ids) {
        $ct++;
        if (!defined $current or $current > $score{$pause_id}{average_core_kwalitee}) {
            $rank                   = $ct;
            $score{$pause_id}{rank} = $rank;
            $current                = $score{$pause_id}{average_core_kwalitee};
        } else {
            $score{$pause_id}{rank} = $rank;
        }
        $authors->update_ranking($pause_id, @{ $score{$pause_id} }{qw/rank average_core_kwalitee average_kwalitee/});
    }
}

1;
