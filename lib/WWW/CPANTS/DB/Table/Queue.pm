package WWW::CPANTS::DB::Table::Queue;

use Mojo::Base 'WWW::CPANTS::DB::Table', -signatures;

sub columns ($self) { (
    [id         => '_serial_'],
    [uid        => '_upload_id_', unique => 1],
    [path       => '_cpan_path_'],
    [priority   => 'tinyint', default => 0],
    [pid        => 'smallint', default => 0],
    [released   => '_epoch_'],
    [created_at => '_epoch_'],
    [started_at => '_epoch_'],
    [suspended  => '_bool_', default => 0],
) }

sub indices ($self) { (
    ['priority desc', 'released desc'],
) }

sub is_not_empty ($self) {
    my $sql = <<~';';
    SELECT 1 FROM queue
    WHERE pid = 0 AND suspended = 0
    LIMIT 1
    ;
    $self->select_col($sql);
}

sub count ($self) {
    my $sql = <<~';';
    SELECT COUNT(id) FROM queue
    WHERE pid = 0 AND suspended = 0
    ;
    $self->select_col($sql);
}

sub next ($self) {
    my $updater = <<~';';
    UPDATE queue SET pid = ?, started_at = ?
    WHERE id = (:id)
    ;
    my $selector = <<~';';
    SELECT id FROM queue
    WHERE pid = 0 AND suspended = 0
    ORDER BY priority DESC, released DESC
    LIMIT 1
    ;
    my $rowid = $self->update_and_get_updated_rowid($updater, $selector, $$, time);

    my $sql = <<~';';
    SELECT uid, path FROM queue WHERE id = ?
    ;
    $self->select($sql, $rowid);
}

sub dequeue ($self, $uid) {
    my $sql = <<~';';
    DELETE FROM queue WHERE uid = ? AND pid = ?
    ;
    $self->delete($sql, $uid, $$);
}

sub select_unfinished_pids ($self, $before = time - 24 * 60 * 60) {
    my $sql = <<~';';
    SELECT pid FROM queue WHERE pid > 0 and started_at < ?
    ;
    $self->select_all_col($sql, $before);
}

sub delete_by_pid ($self, $pid) {
    my $sql = <<~';';
    DELETE FROM queue WHERE pid = ?
    ;
    $self->delete($sql, $pid);
}

sub select_suspended_uids ($self, $limit = 3) {
    my $sql = <<~';';
    SELECT uid FROM queue WHERE suspended = 1
    ORDER BY priority DESC, released DESC
    ;
    $self->select_all_col($sql, { limit => $limit });
}

sub select_paths_by_pid ($self, $pid) {
    my $sql = <<~';';
    SELECT path FROM queue WHERE pid = ?
    ;
    $self->select_all_col($sql, $pid);
}

sub unsuspend_by_uids ($self, $uids) {
    my $sql = <<~';';
    UPDATE queue SET suspended = 0 WHERE uid IN (:uids)
    ;
    $self->update($sql, [uids => $uids]);
}

1;
