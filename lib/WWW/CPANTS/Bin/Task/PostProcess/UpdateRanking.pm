package WWW::CPANTS::Bin::Task::PostProcess::UpdateRanking;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;

our @READ  = qw/Authors Kwalitee/;
our @WRITE = qw/Authors/;

sub run ($self, @args) {
    my $db      = $self->db;
    my $authors = $db->table('Authors');
    my @methods = qw(
        select_all_pause_ids_with_many_cpan_dists
        select_all_pause_ids_with_few_cpan_dists
    );
    for my $method (@methods) {
        $self->_update_ranking($authors->$method);
    }
}

sub _update_ranking ($self, $pause_ids) {
    my $authors  = $self->db->table('Authors');
    my $averages = $self->_calc_averages($pause_ids);

    my ($rank, $ct, $current) = (0, 0, undef);
    for my $row (@$averages) {
        my ($pause_id, $core_average, $average) = @$row;
        $ct++;
        if (!defined $current or $current > $core_average) {
            $rank    = $ct;
            $current = $core_average;
        }
        $authors->update_ranking($pause_id, $rank, $core_average, $average);
    }
}

sub _calc_averages ($self, $pause_ids) {
    my $kwalitee = $self->db->table('Kwalitee');

    # TODO: benchmark this against the one-query version
    my @averages;
    for my $pause_id (@$pause_ids) {
        my ($kwalitee_sum, $core_kwalitee_sum, $total) = (0, 0, 0);
        my $rows = $kwalitee->select_all_scores_for_author($pause_id);
        for my $row (@{ $rows // [] }) {
            next if !$row->{kwalitee} && !$row->{core_kwalitee};
            $kwalitee_sum      += $row->{kwalitee};
            $core_kwalitee_sum += $row->{core_kwalitee};
            $total++;
        }
        my $average      = $total ? $kwalitee_sum / $total      : 0;
        my $core_average = $total ? $core_kwalitee_sum / $total : 0;
        push @averages, [
            $pause_id,
            sprintf("%.2f", $core_average),
            sprintf("%.2f", $average),
        ];
    }
    [sort { $b->[1] <=> $a->[1] or $a->[0] cmp $b->[0] } @averages];
}

1;
