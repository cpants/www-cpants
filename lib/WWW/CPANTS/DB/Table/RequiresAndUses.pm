package WWW::CPANTS::DB::Table::RequiresAndUses;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use WWW::CPANTS::Util::SQL;
use parent 'WWW::CPANTS::DB::Table';

sub columns ($self) { (
    [uid      => '_upload_id_', primary => 1],
    [pause_id => '_pause_id_'],
    [requires => '_json_'],
    [uses     => '_json_'],
) }

sub select_requires_by_uid ($self, $uid) {
    my $sth = $self->{sth}{requires_by_uid} //= $self->prepare(qq[
    SELECT requires FROM requires_and_uses WHERE uid = ?
  ]);
    $self->select_col($sth, $uid);
}

sub update_requires_and_uses ($self, $uid, $pause_id, $requires, $uses) {
    my $sth = $self->{sth}{update} //= $self->prepare(qq[
    UPDATE requires_and_uses
    SET pause_id = ?, requires = ?, uses = ?
    WHERE uid = ?
  ]);
    $sth->execute($pause_id, $requires, $uses, $uid);
}

sub delete_by_uids ($self, $uids) {
    my $quoted_uids = $self->quote_and_concat($uids);
    $self->delete(qq[
    DELETE FROM requires_and_uses WHERE uid IN ($quoted_uids)
  ]);
}

1;
