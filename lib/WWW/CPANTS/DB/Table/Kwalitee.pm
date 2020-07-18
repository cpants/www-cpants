package WWW::CPANTS::DB::Table::Kwalitee;

use Mojo::Base 'WWW::CPANTS::DB::Table', -signatures;
use WWW::CPANTS::Model::Kwalitee;

has 'kwalitee' => \&_build_kwalitee;

sub columns ($self) { (
    [uid          => '_upload_id_', primary => 1],
    [pause_id     => '_pause_id_'],
    [distribution => '_dist_name_'],
    [released     => '_epoch_'],
    [year         => '_year_'],
    [latest        => '_bool_', default => 0],
    [cpan          => '_bool_', default => 1],
    [kwalitee      => 'float'],
    [core_kwalitee => 'float'],
    (map { [$_ => 'tinyint', default => -1] } $self->kwalitee->names->@*),
) }

sub _build_kwalitee ($self) {
    WWW::CPANTS::Model::Kwalitee->new;
}

sub select_all_scores_for_author ($self, $pause_id) {
    my $sql = <<~';';
    SELECT kwalitee, core_kwalitee FROM kwalitee
    WHERE pause_id = ? AND latest = 1
    ;
    $self->select_all($sql, $pause_id);
}

sub select_all_zero_kwalitee ($self) {
    my $sql = <<~';';
    SELECT * FROM kwalitee WHERE kwalitee = 0
    ;
    $self->select_all($sql);
}

sub select_scores_by_uid ($self, $uid) {
    my $sql = <<~';';
    SELECT uid, core_kwalitee, kwalitee FROM kwalitee
    WHERE uid = ?
    ;
    $self->select($sql, $uid);
}

sub select_all_by_uids ($self, $uids) {
    my $sql = <<~';';
    SELECT * FROM kwalitee WHERE uid IN (:uids)
    ;
    $self->select_all($sql, [uids => $uids]);
}

sub delete_by_uids ($self, $uids) {
    my $sql = <<~';';
    DELETE FROM kwalitee WHERE uid IN (:uids)
    ;
    $self->delete($sql, [uids => $uids]);
}

sub update_kwalitee ($self, $uid, $pause_id, $dist, $year, $kwalitee = {}) {
    my @names        = sort $self->kwalitee->names->@*;
    my $placeholders = join ', ', map { "$_ = ?" } @names;
    my $sql          = <<~";";
    UPDATE kwalitee
    SET
      pause_id = ?,
      distribution = ?,
      year = ?,
      core_kwalitee = ?,
      kwalitee = ?,
      $placeholders
    WHERE uid = ?
    ;
    $self->update(
        $sql,
        $pause_id,
        $dist,
        $year,
        @$kwalitee{ qw/core_kwalitee kwalitee/, @names },
        $uid,
    );
}

sub select_all_core_kwalitee_of ($self, $uids) {
    my $sql = <<~';';
    SELECT uid, core_kwalitee FROM kwalitee
    WHERE uid IN (:uids)
    ;
    $self->select_all($sql, [uids => $uids]);
}

sub unmark_latest ($self, $uid) {
    my $sql = <<~';';
    UPDATE kwalitee SET latest = 0 WHERE uid = ?
    ;
    $self->update($sql, $uid);
}

sub mark_latest ($self, $uid) {
    my $sql = <<~';';
    UPDATE kwalitee SET latest = 1 WHERE uid = ?
    ;
    $self->update($sql, $uid);
}

sub mark_backpan ($self, $uids) {
    my $sql = <<~';';
    UPDATE kwalitee SET cpan = 0 WHERE uid IN (:uids)
    ;
    my @copy = @$uids;
    while (my @part_of_uids = splice @copy, 0, 500) {
        $self->update($sql, [uids => \@part_of_uids]);
    }
}

sub mark_cpan ($self, $uids) {
    my $sql = <<~';';
    UPDATE kwalitee SET cpan = 1 WHERE uid IN (:uids)
    ;
    my @copy = @$uids;
    while (my @part_of_uids = splice @copy, 0, 500) {
        $self->update($sql, [uids => \@part_of_uids]);
    }
}

sub fails_in ($self, $name, $type, $limit = 25, $offset = 0) {
    my $cond = "($name IS NOT NULL AND $name = 0)";
    $cond .= " AND $type = 1" if $type =~ /\A(?:latest|cpan)\z/;

    my $sql = <<~";";
    SELECT uid FROM kwalitee
    WHERE $cond
    ORDER BY released DESC
    ;
    $self->select_all_col($sql, { limit => $limit, offset => $offset });
}

sub count_fails_in ($self, $name, $type = 'backpan') {
    my $cond = "($name IS NOT NULL AND $name = 0)";
    $type //= 'backpan';
    if ($type eq 'latest') {
        $cond .= " AND latest = 1";
    } elsif ($type eq 'cpan') {
        $cond .= " AND cpan = 1";
    }
    my $sql = <<~";";
    SELECT COUNT(*) FROM kwalitee
    WHERE $cond
    ;
    $self->select_col($sql);
}

sub count_fails ($self) {
    my @cols = (
        "SUM(1) AS backpan_total",
        "SUM(CASE WHEN cpan = 1 THEN 1 ELSE 0 END) AS cpan_total",
        "SUM(CASE WHEN latest = 1 THEN 1 ELSE 0 END) AS latest_total",
    );
    for my $name ($self->kwalitee->names->@*) {
        push @cols, "SUM(CASE WHEN $name = 0 THEN 1 ELSE 0 END) AS backpan_$name";
        push @cols, "SUM(CASE WHEN $name = 0 AND cpan = 1 THEN 1 ELSE 0 END) AS cpan_$name";
        push @cols, "SUM(CASE WHEN $name = 0 AND latest = 1 THEN 1 ELSE 0 END) AS latest_$name";
    }
    my $concat_cols = join ",\n    ", @cols;
    my $sql         = <<~";";
    SELECT
      $concat_cols
    FROM kwalitee
    ;
    $self->select($sql);
}

sub yearly_stats_for ($self, $name) {
    my $sql = <<~";";
    SELECT
      year,
      SUM(1) AS backpan_uploads,
      SUM(CASE WHEN cpan = 1 THEN 1 ELSE 0 END) AS cpan_uploads,
      SUM(CASE WHEN latest = 1 THEN 1 ELSE 0 END) AS latest_uploads,
      SUM(CASE WHEN ($name IS NOT NULL AND $name = 0) THEN 1 ELSE 0 END) AS backpan_fails,
      SUM(CASE WHEN cpan = 1 AND ($name IS NOT NULL AND $name = 0) THEN 1 ELSE 0 END) AS cpan_fails,
      SUM(CASE WHEN latest = 1 AND ($name IS NOT NULL AND $name = 0) THEN 1 ELSE 0 END) AS latest_fails
    FROM kwalitee
    GROUP BY year
    ORDER BY year DESC
    LIMIT 10
    ;
    $self->select_all($sql);
}

sub author_stats_of_the_year ($self, $year, $pause_ids) {
    my $cond = $year ? '=' : '!=';
    my $sql  = <<~";";
    SELECT
      AVG(kwalitee) AS average_kwalitee,
      AVG(core_kwalitee) AS average_core_kwalitee,
      COUNT(distribution) AS num_of_dists
    FROM (
      SELECT kwalitee, core_kwalitee, distribution
      FROM kwalitee
      WHERE year $cond ? AND pause_id IN (:pause_ids)
      GROUP BY distribution
      HAVING released = MAX(released)
    )
    ;
    $self->select($sql, $year, [pause_ids => $pause_ids]);
}

1;
