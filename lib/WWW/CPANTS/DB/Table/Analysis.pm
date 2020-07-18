package WWW::CPANTS::DB::Table::Analysis;

use Mojo::Base 'WWW::CPANTS::DB::Table', -signatures;

sub columns ($self) { (
    [uid              => '_upload_id_', primary => 1],
    [path             => '_cpan_path_'],
    [json             => '_json_'],
    [cpants_revision  => '_revision_', default => 0],
    [released         => '_epoch_'],
    [last_analyzed_at => '_epoch_'],
    [ignored          => '_bool_', default => 0],
) }

sub select_json_by_uid ($self, $uid) {
    my $sql = <<~';';
    SELECT json FROM analysis WHERE uid = ?
    ;
    $self->select_col($sql, $uid);
}

sub update_analysis ($self, $row) {
    my $sql = <<~';';
    UPDATE analysis
    SET last_analyzed_at = ?, json = ?, cpants_revision = ?
    WHERE uid = ?
    ;
    $self->update($sql, time, @$row{qw/json cpants_revision uid/});
}

sub delete_by_uids ($self, $uids) {
    my $sql = <<~';';
    DELETE FROM analysis WHERE uid IN (:uids)
    ;
    $self->delete($sql, [uids => $uids]);
}

sub mark_ignored ($self, $uid) {
    my $sql = <<~';';
    UPDATE analysis
    SET ignored = 1, last_analyzed_at = ?
    WHERE uid = ?
    ;
    $self->update($sql, time, $uid);
}

sub iterate_rows_with_older_revision ($self, $cpants_revision = 1) {
    my $sql = <<~';';
    SELECT uid, path, cpants_revision, released FROM analysis
    WHERE cpants_revision < ? AND ignored = 0
    ;
    $self->iterate($sql, $cpants_revision);
}

sub count_older_revisions ($self, $cpants_revision = 1) {
    my $sql = <<~';';
    SELECT COUNT(*) AS count FROM analysis
    WHERE cpants_revision < ? AND ignored = 0
    ;
    $self->select_col($sql, $cpants_revision);
}

1;
