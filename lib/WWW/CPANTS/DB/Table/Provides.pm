package WWW::CPANTS::DB::Table::Provides;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use WWW::CPANTS::Util::SQL;
use parent 'WWW::CPANTS::DB::Table';

sub columns ($self) { (
    [uid           => '_upload_id_', primary => 1],
    [pause_id      => '_pause_id_'],
    [modules       => '_json_'],
    [provides      => '_json_'],
    [special_files => '_json_'],
    [unauthorized  => '_json_'],
) }

sub select_by_uid ($self, $uid) {
    my $sth = $self->{sth}{select_by_uid} //= $self->prepare(qq[
    SELECT * FROM provides WHERE uid = ?
  ]);
    $self->select($sth, $uid);
}

sub delete_by_uids ($self, $uids) {
    my $quoted_uids = $self->quote_and_concat($uids);
    $self->delete(qq[
    DELETE FROM provides WHERE uid IN ($quoted_uids)
  ]);
}

sub update_provides ($self, $uid, $pause_id, $modules, $provides, $special_files, $unauthorized) {
    my $sth = $self->{sth}{update} //= $self->prepare(qq[
    UPDATE provides
    SET
      pause_id = ?,
      modules = ?,
      provides = ?,
      special_files = ?,
      unauthorized = ?
    WHERE uid = ?
  ]);
    $sth->execute($pause_id, $modules, $provides, $special_files, $unauthorized, $uid);
}

1;
