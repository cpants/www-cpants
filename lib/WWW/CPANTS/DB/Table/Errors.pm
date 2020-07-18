package WWW::CPANTS::DB::Table::Errors;

use Mojo::Base 'WWW::CPANTS::DB::Table', -signatures;
use WWW::CPANTS::Util::JSON qw/decode_if_json/;

sub columns ($self) { (
    [id       => '_serial_'],
    [uid      => '_upload_id_'],
    [category => 'varchar(50)'],
    [error    => 'text'],
) }

sub indices ($self) { (
    { unique => 1, columns => [qw/uid category/] },
) }

sub select_errors_by_uid ($self, $uid) {
    my $sql = <<~';';
    SELECT id, category, error FROM errors
    WHERE uid = ?
    ;
    $self->select_all($sql, $uid);
}

sub select_category_errors_by_uids ($self, $category, $uids) {
    my $sql = <<~';';
    SELECT uid, error FROM errors
    WHERE category = ? AND uid IN (:uids)
    ;
    $self->select_all($sql, $category, [uids => $uids]);
}

sub select_all_errors_of ($self, $uid) {
    my $sql = <<~';';
    SELECT category, error FROM errors
    WHERE uid = ?
    ;
    my $rows = $self->select_all($sql, $uid);
    $_->{error} = decode_if_json($_->{error}) for @$rows;
    $rows;
}

sub select_all_errors_on ($self, $category) {
    my $sql = <<~';';
    SELECT id, uid, error FROM errors
    WHERE category = ?
    ;
    $self->select_all($sql, $category);
}

sub update_error_by_id ($self, $id, $error) {
    my $sql = <<~';';
    UPDATE errors SET error = ? WHERE id = ?
    ;
    $self->update($sql, $error, $id);
}

sub delete_errors_by_id ($self, $ids) {
    my $sql = <<~';';
    DELETE FROM errors WHERE id IN (:ids)
    ;
    $self->delete($sql, [ids => $ids]);
}

sub delete_errors_by_uid ($self, $uid) {
    my $sql = <<~';';
    DELETE FROM errors WHERE uid = ?
    ;
    $self->delete($sql, $uid);
}

1;
