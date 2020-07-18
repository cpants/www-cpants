package WWW::CPANTS::DB::Table::Queue;

use WWW::CPANTS;
use WWW::CPANTS::Util::SQL;
use parent 'WWW::CPANTS::DB::Table';

sub columns ($self) { (
    [id         => '_sereal_'],
    [uid        => '_upload_id_', unique => 1],
    [path       => '_cpan_path_'],
    [priority   => 'tinyint', default => 0],
    [pid        => 'smallint', default => 0],
    [created_at => '_epoch_'],
    [started_at => '_epoch_'],
) }

sub indices ($self) { (
    ['priority desc', 'id'],
) }

sub is_not_empty ($self) {
    my $sth = $self->{sth}{is_not_empty} //= $self->prepare(qq[
    SELECT 1 FROM queue
    WHERE pid IS NULL OR pid = 0
    LIMIT 1
  ]);
    $self->select_col($sth);
}

sub count ($self) {
    my $sth = $self->{sth}{count} //= $self->prepare(qq[
    SELECT COUNT(id) FROM queue
    WHERE pid IS NULL OR pid = 0
  ]);
    $self->select_col($sth);
}

sub next ($self) {
    my $update_sth = $self->{sth}{mark_update} //= $self->prepare(qq[
    UPDATE queue SET pid = ?, started_at = ?
    WHERE id = (
      SELECT id FROM queue
      WHERE pid IS NULL OR pid = 0
      ORDER BY priority DESC, id ASC
      LIMIT 1
    )
  ]);
    my $rowid = $self->update_and_get_updated_rowid($update_sth, $$, time);

    my $uid_sth = $self->{sth}{mark_select} //= $self->prepare(qq[
    SELECT uid, path FROM queue WHERE id = ?
  ]);
    $self->select($uid_sth, $rowid);
}

sub dequeue ($self, $uid) {
    my $sth = $self->{sth}{dequeue} //= $self->prepare(qq[
    DELETE FROM queue WHERE uid = ? AND pid = ?
  ]);
    $sth->execute($uid, $$);
}

1;
