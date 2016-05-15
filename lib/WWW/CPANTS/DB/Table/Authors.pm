package WWW::CPANTS::DB::Table::Authors;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use WWW::CPANTS::Util::SQL;
use parent 'WWW::CPANTS::DB::Table';

sub columns ($self) {(
  [pause_id => '_pause_id_', primary => 1],
  [whois => '_json_'],
  [introduced => '_epoch_'],
  [has_cpandir => 'tinyint', unsigned => 1, default => 0],
  [cpan_dists => 'smallint', default => 0, unsigned => 1],
  [last_released_on => '_date_'],
  [average_kwalitee => 'float', default => 0],
  [average_core_kwalitee => 'float', default => 0],
  [rank => 'smallint', default => 0, unsigned => 1],
  [json => 'text'],
  [json_updated_at => '_epoch_'],
)}

sub select_all_pause_id_and_whois ($self) {
  $self->select_all(qq[
    SELECT pause_id, whois FROM authors
  ]);
}

sub select_all_pause_ids_ordered_by_cpan_dists ($self) {
  $self->select_all_col(qq[
    SELECT pause_id FROM authors ORDER BY cpan_dists DESC, has_cpandir DESC
  ]);
}

sub select_all_pause_ids_with_many_cpan_dists ($self) {
  $self->select_all_col(qq[
    SELECT pause_id FROM authors
    WHERE cpan_dists >= 5
    ORDER BY cpan_dists DESC
  ]);
}

sub select_all_pause_ids_with_few_cpan_dists ($self) {
  $self->select_all_col(qq[
    SELECT pause_id FROM authors
    WHERE cpan_dists BETWEEN 1 AND 4
    ORDER BY cpan_dists DESC
  ]);
}

sub select_all_pause_ids_with_cpan_dists ($self) {
  $self->select_all_col(qq[
    SELECT pause_id FROM authors
    WHERE cpan_dists > 0
    ORDER BY cpan_dists DESC
  ]);
}

sub select_all_json_updated_at ($self) {
  $self->select_all(qq[
    SELECT pause_id, json_updated_at FROM authors WHERE json_updated_at IS NOT NULL
  ]);
}

sub update_whois ($self, $pause_id, $introduced, $has_cpandir, $whois) {
  my $sth = $self->{sth}{update_whois} //= $self->prepare(qq[
    UPDATE authors
    SET introduced = ?, has_cpandir = ?, whois = ?
    WHERE pause_id = ?
  ]);
  $sth->execute($introduced, $has_cpandir, $whois, $pause_id);
}

sub update_cpan_info ($self, $pause_id, $info) {
  my $sth = $self->{sth}{update_cpan_info} //= $self->prepare(qq[
    UPDATE authors
    SET cpan_dists = ?, last_released_on = ?
    WHERE pause_id = ?
  ]);
  $sth->execute(
    $info->{cpan_dists},
    ymd($info->{last_released_at}),
    $pause_id,
  );
}

sub update_ranking ($self, $pause_id, $rank, $average_core_kwalitee, $average_kwalitee) {
  my $sth = $self->{sth}{update_ranking} //= $self->prepare(qq[
    UPDATE authors
    SET rank = ?, average_core_kwalitee = ?, average_kwalitee = ?
    WHERE pause_id = ?
  ]);
  $sth->execute(
    $rank,
    $average_core_kwalitee,
    $average_kwalitee,
    $pause_id,
  );
}

sub update_json ($self, $pause_id, $json, $updated_at) {
  my $sth = $self->{sth}{update_json} //= $self->prepare(qq[
    UPDATE authors SET json = ?, json_updated_at = ? WHERE pause_id = ?
  ]);
  $sth->execute($json, $updated_at, $pause_id);
}

sub select_ranking_five_or_more ($self, $limit = 50, $offset = 0) {
  my $limit_offset = $self->limit_offset($limit, $offset);
  $self->select_all(qq[
    SELECT * FROM authors
    WHERE cpan_dists >= 5
    ORDER BY rank, last_released_on desc, cpan_dists desc
    $limit_offset
  ]);
}

sub count_authors_with_five_or_more_distributions ($self) {
  $self->select_col(qq[
    SELECT COUNT(pause_id) FROM authors
    WHERE cpan_dists >= 5
  ]);
}

sub select_ranking_less_than_five ($self, $limit = 50, $offset = 0) {
  my $limit_offset = $self->limit_offset($limit, $offset);
  $self->select_all(qq[
    SELECT * FROM authors
    WHERE cpan_dists BETWEEN 1 AND 4
    ORDER BY rank, last_released_on desc, cpan_dists desc
    $limit_offset
  ]);
}

sub count_authors_with_less_than_five_distributions ($self) {
  $self->select_col(qq[
    SELECT COUNT(pause_id) FROM authors
    WHERE cpan_dists BETWEEN 1 AND 4
  ]);
}

1;
