package WWW::CPANTS::DB::Table::Errors;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use WWW::CPANTS::Util::SQL;
use parent 'WWW::CPANTS::DB::Table';

sub columns ($self) { (
    [id       => '_sereal_'],
    [uid      => '_upload_id_'],
    [category => 'varchar(50)'],
    [error    => 'text'],
) }

sub indices ($self) { (
    { unique => 1, columns => [qw/uid category/] },
) }

sub select_errors_by_uid ($self, $uid) {
    my $sth = $self->{sth}{select_by_uid} //= $self->prepare(qq[
    SELECT id, category, error FROM errors
    WHERE uid = ?
  ]);
    $self->select_all($sth, $uid);
}

sub update_errors ($self, $uid, $errors = {}) {
}

sub select_all_errors_of ($self, $uid) {
    my $rows = $self->select_all(
        qq[
    SELECT category, error FROM errors
    WHERE uid = ?
  ], $uid
    );
    $_->{error} = decode_if_json($_->{error}) for @$rows;
    $rows;
}

sub select_all_errors_on ($self, $category) {
    $self->select_all(
        qq[
    SELECT id, uid, error FROM errors
    WHERE category = ?
  ], $category
    );
}

sub update_error_by_id ($self, $id, $error) {
    my $sth = $self->{sth}{update_error_by_id} //= $self->prepare(qq[
    UPDATE errors SET error = ? WHERE id = ?
  ]);
    $sth->execute($error, $id);
}

sub delete_errors_by_id ($self, $ids) {
    my $quoted_ids = $self->quote_and_concat($ids);
    $self->delete(qq[
    DELETE FROM errors WHERE id IN ($quoted_ids)
  ]);
}

1;
