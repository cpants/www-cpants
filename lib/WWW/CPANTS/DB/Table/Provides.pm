package WWW::CPANTS::DB::Table::Provides;

use Mojo::Base 'WWW::CPANTS::DB::Table', -signatures;

sub columns ($self) { (
    [uid           => '_upload_id_', primary => 1],
    [pause_id      => '_pause_id_'],
    [modules       => '_json_'],
    [provides      => '_json_'],
    [special_files => '_json_'],
    [unauthorized  => '_json_'],
) }

sub select_by_uid ($self, $uid) {
    my $sql = <<~';';
    SELECT * FROM provides WHERE uid = ?
    ;
    $self->select($sql, $uid);
}

sub delete_by_uids ($self, $uids) {
    my $sql = <<~';';
    DELETE FROM provides WHERE uid IN (:uids)
    ;
    $self->delete($sql, [uids => $uids]);
}

sub update_provides ($self, $uid, $pause_id, $modules, $provides, $special_files, $unauthorized) {
    my $sql = <<~';';
    UPDATE provides
    SET
      pause_id = ?,
      modules = ?,
      provides = ?,
      special_files = ?,
      unauthorized = ?
    WHERE uid = ?
    ;
    $self->update($sql, $pause_id, $modules, $provides, $special_files, $unauthorized, $uid);
}

1;
