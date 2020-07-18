package WWW::CPANTS::DB::Table::Analysis;

use WWW::CPANTS;
use WWW::CPANTS::Util::SQL;
use parent 'WWW::CPANTS::DB::Table';

sub columns ($self) { (
    [uid  => '_upload_id_', primary => 1],
    [json => '_json_'],
) }

sub iterate_json ($self) {
    $self->iterate(qq[SELECT uid, json FROM analysis]);
}

sub select_json_by_uid ($self, $uid) {
    my $sth = $self->{sth}{select_by_uid} //= $self->prepare(qq[
    SELECT json FROM analysis WHERE uid = ?
  ]);
    $self->select_col($sth, $uid);
}

sub update_analysis ($self, $row) {
    my $sth = $self->{sth}{update} //= $self->prepare(qq[
    UPDATE analysis SET json = ? WHERE uid = ?
  ]);
    $sth->execute(@$row{qw/json uid/});
}

sub delete_by_uids ($self, $uids) {
    my $quoted_uids = $self->quote_and_concat($uids);
    $self->delete(qq[
    DELETE FROM analysis WHERE uid IN ($quoted_uids)
  ]);
}

1;
