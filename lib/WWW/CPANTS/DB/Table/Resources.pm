package WWW::CPANTS::DB::Table::Resources;

use Mojo::Base 'WWW::CPANTS::DB::Table', -signatures;

sub columns ($self) { (
    [uid            => '_upload_id_', primary => 1],
    [pause_id       => '_pause_id_'],
    [resources      => '_json_'],
    [repository_url => 'varchar(255)'],
    [bugtracker_url => 'varchar(255)'],
) }

sub select_by_uid ($self, $uid) {
    my $sql = <<~';';
    SELECT * FROM resources WHERE uid = ?
    ;
    $self->select($sql, $uid);
}

sub delete_by_uids ($self, $uids) {
    my $sql = <<~';';
    DELETE FROM resources WHERE uid IN (:uids)
    ;
    $self->delete($sql, [uids => $uids]);
}

sub update_resources ($self, $uid, $pause_id, $resources, $repository, $bugtracker) {
    my $sql = <<~';';
    UPDATE resources
    SET pause_id = ?, resources = ?, repository_url = ?, bugtracker_url = ?
    WHERE uid = ?
    ;
    $self->update($sql, $pause_id, $resources, $repository, $bugtracker, $uid);
}

1;
