package WWW::CPANTS::DB::Table::RequiresAndUses;

use Mojo::Base 'WWW::CPANTS::DB::Table', -signatures;

sub columns ($self) { (
    [uid      => '_upload_id_', primary => 1],
    [pause_id => '_pause_id_'],
    [requires => '_json_'],
    [uses     => '_json_'],
) }

sub select_requires_by_uid ($self, $uid) {
    my $sql = <<~';';
    SELECT requires FROM requires_and_uses WHERE uid = ?
    ;
    $self->select_col($sql, $uid);
}

sub update_requires_and_uses ($self, $uid, $pause_id, $requires, $uses) {
    my $sql = <<~';';
    UPDATE requires_and_uses
    SET pause_id = ?, requires = ?, uses = ?
    WHERE uid = ?
    ;
    $self->update($sql, $pause_id, $requires, $uses, $uid);
}

sub delete_by_uids ($self, $uids) {
    my $sql = <<~';';
    DELETE FROM requires_and_uses WHERE uid IN (:uids)
    ;
    $self->delete($sql, [uids => $uids]);
}

1;
