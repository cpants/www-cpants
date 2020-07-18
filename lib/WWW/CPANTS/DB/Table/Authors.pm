package WWW::CPANTS::DB::Table::Authors;

use Mojo::Base 'WWW::CPANTS::DB::Table', -signatures;
use WWW::CPANTS::Util::Datetime;

sub columns ($self) { (
    [pause_id     => '_pause_id_', primary => 1],
    [cpan_dists   => 'smallint',   default => 0, unsigned => 1],
    [recent_dists => 'smallint',   default => 0, unsigned => 1],
    [last_release_at       => '_epoch_'],
    [last_new_release_at   => '_epoch_'],
    [average_kwalitee      => 'float', default => 0],
    [average_core_kwalitee => 'float', default => 0],
    [rank                  => 'smallint', default => 0, unsigned => 1],
    [json                  => '_json_'],
    [json_updated_at       => '_epoch_'],
    [has_perl6             => '_bool_', default => 0],
) }

sub indices ($self) { (['cpan_dists desc']) }

sub select_all_by_pause_ids ($self, $pause_ids) {
    my $sql = <<~';';
    SELECT * FROM authors WHERE pause_id IN (:pause_ids)
    ;
    $self->select_all($sql, [pause_ids => $pause_ids]);
}

sub select_all_pause_ids_ordered_by_cpan_dists ($self) {
    my $sql = <<~';';
    SELECT pause_id FROM authors ORDER BY cpan_dists DESC
    ;
    $self->select_all_col($sql);
}

sub select_all_pause_ids_with_many_cpan_dists ($self) {
    my $sql = <<~';';
    SELECT pause_id FROM authors
    WHERE cpan_dists >= 5
    ORDER BY cpan_dists DESC
    ;
    $self->select_all_col($sql);
}

sub select_all_pause_ids_with_few_cpan_dists ($self) {
    my $sql = <<~';';
    SELECT pause_id FROM authors
    WHERE cpan_dists BETWEEN 1 AND 4
    ORDER BY cpan_dists DESC
    ;
    $self->select_all_col($sql);
}

sub select_all_pause_ids_with_cpan_dists ($self) {
    my $sql = <<~';';
    SELECT pause_id FROM authors
    WHERE cpan_dists > 0
    ORDER BY cpan_dists DESC
    ;
    $self->select_all_col($sql);
}

sub update_release_stats ($self, $pause_id, $stats) {
    my $sql = <<~';';
    UPDATE authors
    SET cpan_dists = ?, recent_dists = ?, last_release_at = ?, last_new_release_at = ?
    WHERE pause_id = ?
    ;
    $self->update(
        $sql,
        $stats->{cpan_dists},
        $stats->{recent_dists},
        $stats->{last_release_at},
        $stats->{last_new_release_at},
        uc $pause_id,
    );
}

sub update_ranking ($self, $pause_id, $rank, $average_core_kwalitee, $average_kwalitee) {
    my $sql = <<~';';
    UPDATE authors
    SET rank = ?, average_core_kwalitee = ?, average_kwalitee = ?
    WHERE pause_id = ?
    ;
    $self->update(
        $sql,
        $rank,
        $average_core_kwalitee,
        $average_kwalitee,
        uc $pause_id,
    );
}

sub update_json ($self, $pause_id, $json, $updated_at) {
    my $sql = <<~';';
    UPDATE authors SET json = ?, json_updated_at = ?
    WHERE pause_id = ? AND (json_updated_at IS NULL OR json_updated_at < ?)
    ;
    $self->update($sql, $json, $updated_at, uc $pause_id, $updated_at);
}

sub select_ranking_five_or_more ($self, $limit = 50, $offset = 0) {
    my $sql = <<~';';
    SELECT * FROM authors
    WHERE cpan_dists >= 5
    ORDER BY rank, last_release_at desc, cpan_dists desc
    ;
    $self->select_all($sql, { limit => $limit, offset => $offset });
}

sub count_authors_with_five_or_more_distributions ($self) {
    my $sql = <<~';';
    SELECT COUNT(pause_id) FROM authors
    WHERE cpan_dists >= 5
    ;
    $self->select_col($sql);
}

sub select_ranking_less_than_five ($self, $limit = 50, $offset = 0) {
    my $sql = <<~';';
    SELECT * FROM authors
    WHERE cpan_dists BETWEEN 1 AND 4
    ORDER BY rank, last_release_at desc, cpan_dists desc
    ;
    $self->select_all($sql, { limit => $limit, offset => $offset });
}

sub count_authors_with_less_than_five_distributions ($self) {
    my $sql = <<~';';
    SELECT COUNT(pause_id) FROM authors
    WHERE cpan_dists BETWEEN 1 AND 4
    ;
    $self->select_col($sql);
}

1;
