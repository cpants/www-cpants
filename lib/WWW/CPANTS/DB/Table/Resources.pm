package WWW::CPANTS::DB::Table::Resources;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use WWW::CPANTS::Util::SQL;
use parent 'WWW::CPANTS::DB::Table';

sub columns ($self) {(
  [uid => '_upload_id_', primary => 1],
  [pause_id => '_pause_id_'],
  [resources => '_json_'],
  [repository_url => 'varchar(255)'],
  [bugtracker_url => 'varchar(255)'],
)}

sub delete_by_uids ($self, $uids) {
  my $quoted_uids = $self->quote_and_concat($uids);
  $self->delete(qq[
    DELETE FROM resources WHERE uid IN ($quoted_uids)
  ]);
}

sub update_resources ($self, $uid, $pause_id, $resources, $repository, $bugtracker) {
  my $sth = $self->{sth}{update} //= $self->prepare(qq[
    UPDATE resources
    SET pause_id = ?, resources = ?, repository_url = ?, bugtracker_url = ?
    WHERE uid = ?
  ]);
  $sth->execute($pause_id, $resources, $repository, $bugtracker, $uid);
}

1;
