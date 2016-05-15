package WWW::CPANTS::DB::Table::JobQueue;

use WWW::CPANTS;
use WWW::CPANTS::Util::SQL;
use parent 'WWW::CPANTS::DB::Table';

sub columns ($self) {(
  [id => '_sereal_'],
  [name => 'varchar(255)', unique => 1],
  [args => 'text'],
  [priority => 'tinyint', default => 0],
  [pid => 'smallint', default => 0],
  [created_at => '_epoch_'],
  [started_at => '_epoch_'],
)}

sub indices ($self) {(
  ['priority desc', 'id'],
)}

sub is_not_empty ($self) {
  my $sth = $self->{sth}{is_not_empty} //= $self->prepare(qq[
    SELECT 1 FROM job_queue
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
    UPDATE job_queue SET pid = ?, started_at = ?
    WHERE id = (
      SELECT id FROM job_queue
      WHERE pid IS NULL OR pid = 0
      ORDER BY priority DESC, id ASC
      LIMIT 1
    )
  ]);
  my $rowid = $self->update_and_get_updated_rowid($update_sth, $$, time);

  my $uid_sth = $self->{sth}{mark_select} //= $self->prepare(qq[
    SELECT id, name, args FROM job_queue WHERE id = ?
  ]);
  $self->select($uid_sth, $rowid);
}

sub dequeue ($self, $id) {
  my $sth = $self->{sth}{dequeue} //= $self->prepare(qq[
    DELETE FROM job_queue WHERE id = ? AND pid = ?
  ]);
  $sth->execute($id, $$);
}

sub force_dequeue ($self, $id) {
  my $sth = $self->{sth}{force_dequeue} //= $self->prepare(qq[
    DELETE FROM job_queue WHERE id = ?
  ]);
  $sth->execute($id);
}

sub select_all_running_jobs ($self) {
  my $sth = $self->{sth}{all_running_jobs} //= $self->prepare(qq[
    SELECT * FROM job_queue
    WHERE pid > 0
  ]);
  $self->select_all($sth);
}

1;
