package WWW::CPANTS::DB::Table::Kwalitee;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use WWW::CPANTS::Util::SQL;
use WWW::CPANTS::Util::Kwalitee;
use parent 'WWW::CPANTS::DB::Table';

sub columns ($self) { (
    [uid           => '_upload_id_', primary => 1],
    [pause_id      => '_pause_id_'],
    [released      => '_epoch_'],
    [year          => 'smallint'],
    [latest        => 'tinyint', unsigned => 1, default => 0],
    [cpan          => 'tinyint', unsigned => 1, default => 1],
    [kwalitee      => 'float'],
    [core_kwalitee => 'float'],
    (map { [$_ => 'tinyint', default => -1] } @{ kwalitee_indicator_names() }),
) }

sub select_all_scores_for_author ($self, $pause_id) {
    my $sth = $self->{sth}{all_scores_for_author} //= $self->prepare(qq[
    SELECT kwalitee, core_kwalitee FROM kwalitee
    WHERE pause_id = ? AND latest = 1 AND cpan = 1
  ]);
    $self->select_all($sth, $pause_id);
}

sub select_all_zero_kwalitee ($self) {
    $self->select_all(qq[
    SELECT * FROM kwalitee WHERE kwalitee = 0
  ]);
}

sub select_scores_by_uid ($self, $uid) {
    my $sth = $self->{sth}{scores_by_uid} //= $self->prepare(qq[
    SELECT uid, core_kwalitee, kwalitee FROM kwalitee
    WHERE uid = ?
  ]);
    $self->select($sth, $uid);
}

sub select_all_by_uids ($self, $uids) {
    my $quoted_uids = $self->quote_and_concat($uids);
    $self->select_all(qq[
    SELECT * FROM kwalitee WHERE uid IN ($quoted_uids)
  ]);
}

sub delete_by_uids ($self, $uids) {
    my $quoted_uids = $self->quote_and_concat($uids);
    $self->delete(qq[
    DELETE FROM kwalitee WHERE uid IN ($quoted_uids)
  ]);
}

sub update_kwalitee ($self, $uid, $pause_id, $year, $kwalitee = {}) {
    my $sth = $self->{sth}{update} //= do {
        my $placeholders = join ', ', map { "$_ = ?" } @{ kwalitee_indicator_names() };
        $self->prepare(qq[
      UPDATE kwalitee
      SET 
        pause_id = ?,
        year = ?,
        core_kwalitee = ?,
        kwalitee = ?,
        $placeholders
      WHERE uid = ?
    ]);
    };
    $sth->execute(
        $pause_id,
        $year,
        @$kwalitee{ qw/core_kwalitee kwalitee/, @{ kwalitee_indicator_names() } },
        $uid,
    );
}

sub select_all_core_kwalitee_of ($self, $uids) {
    my $quoted_uids = $self->quote_and_concat($uids);
    $self->select_all(qq[
    SELECT uid, core_kwalitee FROM kwalitee
    WHERE uid IN ($quoted_uids)
  ]);
}

sub unmark_latest ($self, $uid) {
    my $sth = $self->{sth}{unmark_latest} //= $self->prepare(qq[
    UPDATE kwalitee SET latest = 0 WHERE uid = ?
  ]);
    $sth->execute($uid);
}

sub mark_latest ($self, $uid) {
    my $sth = $self->{sth}{mark_latest} //= $self->prepare(qq[
    UPDATE kwalitee SET latest = 1 WHERE uid = ?
  ]);
    $sth->execute($uid);
}

sub fails_in ($self, $name, $type, $limit = 25, $offset = 0) {
    my $limit_offset = $self->limit_offset($limit, $offset);
    my $cond         = "($name IS NOT NULL AND $name = 0)"
        . (
          $type eq 'latest' ? " AND latest = 1"
        : $type eq 'cpan'   ? " AND cpan = 1"
        :                     ""
        );
    $self->select_all_col(qq[
    SELECT uid FROM kwalitee
    WHERE $cond
    ORDER BY released DESC
    $limit_offset
  ]);
}

sub count_fails_in ($self, $name, $type = 'backpan') {
    my $cond = "($name IS NOT NULL AND $name = 0)";
    $type //= 'backpan';
    if ($type eq 'latest') {
        $cond .= " AND latest = 1";
    } elsif ($type eq 'cpan') {
        $cond .= " AND cpan = 1";
    }
    $self->select_col(qq[
    SELECT COUNT(*) FROM kwalitee
    WHERE $cond
  ]);
}

sub count_fails ($self) {
    my @cols = (
        "SUM(1) AS backpan_total",
        "SUM(CASE WHEN cpan = 1 THEN 1 ELSE 0 END) AS cpan_total",
        "SUM(CASE WHEN latest = 1 THEN 1 ELSE 0 END) AS latest_total",
    );
    for my $name (@{ kwalitee_indicator_names() }) {
        push @cols, "SUM(CASE WHEN $name = 0 THEN 1 ELSE 0 END) AS backpan_$name";
        push @cols, "SUM(CASE WHEN $name = 0 AND cpan = 1 THEN 1 ELSE 0 END) AS cpan_$name";
        push @cols, "SUM(CASE WHEN $name = 0 AND latest = 1 THEN 1 ELSE 0 END) AS latest_$name";
    }
    my $concat_cols = join ",\n    ", @cols;
    $self->select(qq[
    SELECT
      $concat_cols
    FROM kwalitee
  ]);
}

sub yearly_stats_for ($self, $name) {
    $self->select_all(qq[
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
  ]);
}

1;
