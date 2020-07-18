package WWW::CPANTS::DB::Table::Uploads;

use Mojo::Base 'WWW::CPANTS::DB::Table', -signatures;
use WWW::CPANTS::Util::Datetime;

our $RECENT = 180;

sub columns ($self) { (
    [id             => '_serial_'],
    [uid            => '_upload_id_', unique => 1],
    [path           => '_cpan_path_'],
    [author         => '_pause_id_'],
    [name           => '_dist_name_'],
    [version        => '_version_string_'],
    [version_number => 'float'],
    [released       => '_epoch_'],
    [year           => '_year_'],
    [cpan           => '_bool_', default => 1],
    [stable         => '_bool_', default => 1],
    [first          => '_bool_', default => 0],
    [latest         => '_bool_', default => 0],
    [size           => '_int_'],
) }

sub indices ($self) { (
    [qw/name version/],
) }

sub select_new_uids ($self, $uids) {
    my $sql = <<~';';
    SELECT uid FROM uploads WHERE uid IN (:uids)
    ;
    my $existing_uids = $self->select_all_col($sql, [uids => $uids]);

    return $uids if !$existing_uids or !@$existing_uids;

    my $map = map { $_ => 1 } @$existing_uids;
    [grep { !$map->{$_} } @$uids];
}

sub unmark_latest ($self, $uid) {
    my $sql = <<~';';
    UPDATE uploads SET latest = 0 WHERE uid = ?
    ;
    $self->update($sql, $uid);
}

sub mark_latest ($self, $uid) {
    my $sql = <<~';';
    UPDATE uploads SET latest = 1 WHERE uid = ?
    ;
    $self->update($sql, $uid);
}

sub unmark_first ($self, $uid) {
    my $sql = <<~';';
    UPDATE uploads SET first = 0 WHERE uid = ?
    ;
    $self->update($sql, $uid);
}

sub mark_first ($self, $uid) {
    my $sql = <<~';';
    UPDATE uploads SET first = 1 WHERE uid = ?
    ;
    $self->update($sql, $uid);
}

sub select_by_uid ($self, $uid) {
    my $sql = <<~';';
    SELECT * FROM uploads WHERE uid = ?
    ;
    $self->select($sql, $uid);
}

sub select_all_by_uids ($self, $uids) {
    my $sql = <<~';';
    SELECT * FROM uploads WHERE uid IN (:uids)
    ;
    $self->select_all($sql, [uids => $uids]);
}

sub select_path_by_uid ($self, $uid) {
    my $sql = <<~';';
    SELECT path FROM uploads WHERE uid = ?
    ;
    $self->select_col($sql, $uid);
}

sub select_name_by_uid ($self, $uid) {
    my $sql = <<~';';
    SELECT name FROM uploads WHERE uid = ?
    ;
    $self->select_col($sql, $uid);
}

sub select_all_by_author ($self, $author) {
    my $sql = <<~';';
    SELECT * FROM uploads WHERE author = ?
    ;
    $self->select_all($sql, $author);
}

sub select_all_cpan_uids_by_author ($self, $author) {
    my $sql = <<~';';
    SELECT uid FROM uploads WHERE author = ? AND cpan = 1
    ;
    $self->select_all_col($sql, $author);
}

sub select_release_stats ($self) {
    my $sql = <<~';';
    SELECT
      author AS pause_id,
      COUNT(DISTINCT(name)) AS cpan_dists,
      COUNT(DISTINCT(CASE WHEN released > ? THEN name ELSE NULL END)) AS recent_dists,
      MAX(released) AS last_release_at,
      MAX(CASE first WHEN 1 THEN released ELSE 0 END) AS last_new_release_at
    FROM uploads
    WHERE cpan = 1
    GROUP BY author
    ;
    $self->select_all($sql, days_ago($RECENT)->epoch);
}

sub select_recent_by_author ($self, $author, $limit = 50, $offset = 0) {
    my $sql = <<~';';
    SELECT * FROM uploads WHERE author = ?
    ORDER BY released DESC
    ;
    $self->select_all($sql, $author, { limit => $limit, offset => $offset });
}

sub mark_backpan ($self, $uids) {
    my $sql = <<~';';
    UPDATE uploads SET cpan = 0 WHERE uid IN (:uids)
    ;
    my @copy = @$uids;
    while (my @part_of_uids = splice @copy, 0, 500) {
        $self->update($sql, [uids => \@part_of_uids]);
    }
}

sub mark_cpan ($self, $uids) {
    my $sql = <<~';';
    UPDATE uploads SET cpan = 1 WHERE uid IN (:uids)
    ;
    my @copy = @$uids;
    while (my @part_of_uids = splice @copy, 0, 500) {
        $self->update($sql, [uids => \@part_of_uids]);
    }
}

sub delete_by_uids ($self, $uids) {
    my $sql = <<~';';
    DELETE FROM uploads WHERE uid IN (:uids)
    ;
    $self->delete($sql, [uids => $uids]);
}

sub select_all_recent_releases ($self, $limit = 50, $offset = 0) {
    my $sql = <<~';';
    SELECT * FROM uploads
    WHERE cpan = 1 AND released > ?
    ORDER BY released DESC
    ;
    $self->select_all($sql, days_ago($RECENT)->epoch, { limit => $limit, offset => $offset });
}

sub count_recent_releases ($self) {
    my $sql = <<~';';
    SELECT COUNT(id) FROM uploads
    WHERE cpan = 1 AND released > ?
    ;
    $self->select_col($sql, days_ago($RECENT)->epoch);
}

sub search_for ($self, $name) {
    return [] unless $name =~ /\A[A-Za-z0-9_\-]+\z/;
    my $uc_name = uc $name;
    my $concat  = $self->handle->concat_expr('?', q{'~'});
    my $sql     = <<~";";
    SELECT author, '' AS name
      FROM uploads WHERE author BETWEEN ? AND $concat GROUP BY author
    UNION
    SELECT '' AS author, name
      FROM uploads WHERE name BETWEEN ? AND $concat GROUP BY name
      ORDER BY author, name
    ;
    $self->select_all($sql, $uc_name, $uc_name, $name, $name);
}

sub select_all_recent_releases_by ($self, $pause_id, $limit = 25, $offset = 0) {
    my $sql = <<~';';
    SELECT * FROM uploads
    WHERE cpan = 1 AND author = ? AND released > ?
    ORDER BY released DESC
    ;
    $self->select_all($sql, $pause_id, days_ago($RECENT)->epoch, { limit => $limit, offset => $offset });
}

sub count_recent_releases_by ($self, $pause_id) {
    my $sql = <<~';';
    SELECT COUNT(id) FROM uploads
    WHERE cpan = 1 AND author = ? AND released > ?
    ;
    $self->select_col($sql, $pause_id, days_ago($RECENT)->epoch);
}

sub select_all_cpan_distributions_by ($self, $pause_id, $limit = 50, $offset = 0) {
    my $sql = <<~';';
    SELECT * FROM uploads
    WHERE cpan = 1 AND author = ?
    GROUP BY name
    HAVING released = MAX(released)
    ORDER BY released DESC
    ;
    $self->select_all($sql, $pause_id, { limit => $limit, offset => $offset });
}

sub count_cpan_distributions_by ($self, $pause_id) {
    my $sql = <<~';';
    SELECT COUNT(id) FROM (
      SELECT * FROM uploads
      WHERE author = ? AND cpan = 1
      GROUP BY name HAVING released = MAX(released)
    ) AS u
    ;
    $self->select_col($sql, $pause_id);
}

sub author_stats_of_the_year ($self, $year, $authors) {
    my $cond  = $year ? '='                            : '!=';
    my $start = $year ? epoch_from_date("$year-01-01") : days_ago(365)->epoch;
    my $sql   = <<~";";
    SELECT
      COUNT(DISTINCT(CASE WHEN released >= ? THEN author END)) AS active_authors,
      COUNT(DISTINCT(name)) AS distributions,
      COUNT(*) AS releases,
      SUM(CASE WHEN first > 0 THEN 1 ELSE 0 END) AS new_releases
    FROM uploads
    WHERE year $cond ? AND author IN (:authors)
    ;
    $self->select($sql, $start, $year, [authors => $authors]);
}

1;
