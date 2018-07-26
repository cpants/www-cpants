package WWW::CPANTS::DB::Table::Uploads;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use WWW::CPANTS::Util::SQL;
use parent 'WWW::CPANTS::DB::Table';

sub columns ($self) {(
  [id => '_sereal_'],
  [uid => '_upload_id_', unique => 1],
  [path => '_cpan_path_'],
  [author => '_pause_id_'],
  [name => '_dist_name_'],
  [version => '_version_string_'],
  [version_number => 'float'],
  [released => '_epoch_'],
  [year => 'smallint', unsigned => 1],
  [cpan => 'tinyint', unsigned => 1, default => 1],
  [stable => 'tinyint', unsigned => 1, default => 1],
  [first => 'tinyint', unsigned => 1, default => 0],
  [latest => 'tinyint', unsigned => 1, default => 0],
  [cpants_revision => 'integer', unsigned => 1, default => 0],
  [ignored => 'integer', unsigned => 1, default => 0],
  [last_analyzed_at => '_epoch_'],
)}

sub indices ($self) {(
  [qw/name version/],
)}

sub unmark_latest ($self, $uid) {
  my $sth = $self->{sth}{unmark_latest} //= $self->prepare(qq[
    UPDATE uploads SET latest = 0 WHERE uid = ?
  ]);
  $sth->execute($uid);
}

sub mark_latest ($self, $uid) {
  my $sth = $self->{sth}{mark_latest} //= $self->prepare(qq[
    UPDATE uploads SET latest = 1 WHERE uid = ?
  ]);
  $sth->execute($uid);
}

sub unmark_first ($self, $uid) {
  my $sth = $self->{sth}{unmark_first} //= $self->prepare(qq[
    UPDATE uploads SET first = 0 WHERE uid = ?
  ]);
  $sth->execute($uid);
}

sub mark_first ($self, $uid) {
  my $sth = $self->{sth}{mark_first} //= $self->prepare(qq[
    UPDATE uploads SET first = 1 WHERE uid = ?
  ]);
  $sth->execute($uid);
}

sub select_by_uid ($self, $uid) {
  my $sth = $self->{sth}{select_by_uid} //= $self->prepare(qq[
    SELECT * FROM uploads WHERE uid = ?
  ]);
  $self->select($sth, $uid);
}

sub select_all_by_uid ($self, $uids) {
  my $quoted_uids = $self->quote_and_concat($uids);
  $self->select_all(qq[
    SELECT * FROM uploads WHERE uid IN ($quoted_uids)
  ]);
}

sub select_path_by_uid($self, $uid) {
  my $sth = $self->{sth}{path_by_uid} //= $self->prepare(qq[
    SELECT path FROM uploads WHERE uid = ?
  ]);
  $self->select_col($sth, $uid);
}

sub select_all_by_author($self, $author) {
  my $sth = $self->{sth}{paths_by_author} //= $self->prepare(qq[
    SELECT * FROM uploads WHERE author = ?
  ]);
  $self->select_all($sth, $author);
}

sub select_recent_by_author($self, $author, $limit = 25, $offset = 0) {
  my $limit_offset = $self->limit_offset($limit, $offset);
  my $sth = $self->{sth}{recent_by_author} //= $self->prepare(qq[
    SELECT * FROM uploads WHERE author = ?
    ORDER BY released DESC
    $limit_offset
  ]);
  $self->select_all($sth, $author);
}

sub mark_backpan ($self, $uid) {
  my $sth = $self->{sth}{mark_backpan} //= $self->prepare(qq[
    UPDATE uploads SET cpan = 0 WHERE uid = ?
  ]);
  $sth->execute($uid);
}

sub mark_cpan ($self, $uid) {
  my $sth = $self->{sth}{mark_cpan} //= $self->prepare(qq[
    UPDATE uploads SET cpan = 1 WHERE uid = ?
  ]);
  $sth->execute($uid);
}

sub delete_by_uids ($self, $uids) {
  my $quoted_uids = $self->quote_and_concat($uids);
  $self->delete(qq[
    DELETE FROM uploads WHERE uid IN ($quoted_uids)
  ]);
}

sub mark_analyzed ($self, $uid, $cpants_revision = 1) {
  my $sth = $self->{sth}{mark_analyzed} //= $self->prepare(qq[
    UPDATE uploads SET cpants_revision = ?, last_analyzed_at = ?
    WHERE uid = ?
  ]);
  $sth->execute($cpants_revision // 1, time, $uid);
}

sub mark_ignored ($self, $uid) {
  my $sth = $self->{sth}{mark_ignored} //= $self->prepare(qq[
    UPDATE uploads
    SET ignored = 1, last_analyzed_at = ?
    WHERE uid = ?
  ]);
  $sth->execute(time, $uid);
}

sub iterate_rows_with_older_revision ($self, $cpants_revision = 1) {
  $self->iterate(qq[
    SELECT uid, path, cpants_revision, cpan FROM uploads
    WHERE cpants_revision < ? AND (ignored IS NULL OR ignored = 0)
  ], $cpants_revision);
}

sub count_older_revisions ($self, $cpants_revision = 1) {
  $self->select_col(qq[
    SELECT COUNT(*) AS count FROM uploads
    WHERE cpants_revision < ? AND (ignored IS NULL OR ignored = 0)
  ], $cpants_revision);
}

sub select_all_recent_releases ($self, $days = 30, $limit = 50, $offset = 0) {
  my $limit_offset = $self->limit_offset($limit, $offset);
  $self->select_all(qq[
    SELECT * FROM uploads
    WHERE cpan = 1 AND released > ?
    ORDER BY released DESC
    $limit_offset
  ], days_ago($days)->epoch);
}

sub count_recent_releases ($self, $days = 7) {
  $self->select_col(qq[
    SELECT COUNT(id) FROM uploads
    WHERE cpan = 1 AND released > ?
  ], days_ago($days)->epoch);
}

sub search_for ($self, $name) {
  return [] unless $name =~ /\A[A-Za-z0-9_\-]+\z/;
  my $uc_name = uc $name;
  $self->select_all(qq/
    SELECT author, '' AS name
      FROM uploads WHERE author BETWEEN ? AND ? || '~' GROUP BY author
    UNION
    SELECT '' AS author, name
      FROM uploads WHERE UPPER(name) BETWEEN ? AND ? || '~' GROUP BY name
    ORDER BY author, name
  /, $uc_name, $uc_name, $uc_name, $uc_name);
}

sub select_all_recent_releases_by ($self, $pause_id, $days = 90, $limit = 25, $offset = 0) {
  my $limit_offset = $self->limit_offset($limit, $offset);
  $self->select_all(qq[
    SELECT * FROM uploads
    WHERE cpan = 1 AND author = ? AND released > ?
    ORDER BY released DESC
    $limit_offset
  ], $pause_id, days_ago($days)->epoch);
}

sub count_recent_releases_by ($self, $pause_id, $days = 90) {
  $self->select_col(qq[
    SELECT COUNT(id) FROM uploads
    WHERE cpan = 1 AND author = ? AND released > ?
  ], $pause_id, days_ago($days)->epoch);
}

sub select_all_cpan_distributions_by ($self, $pause_id, $limit = 50, $offset = 0) {
  my $limit_offset = $self->limit_offset($limit, $offset);
  $self->select_all(qq[
    SELECT * FROM uploads
    WHERE cpan = 1 AND author = ?
    GROUP BY name
    HAVING released = MAX(released)
    ORDER BY released DESC
    $limit_offset
  ], $pause_id);
}

sub count_cpan_distributions_by ($self, $pause_id) {
  $self->select_col(qq[
    SELECT COUNT(id) FROM (
      SELECT * FROM uploads
      WHERE author = ? AND cpan = 1
      GROUP BY name HAVING released = MAX(released)
    )
  ], $pause_id);
}

1;
