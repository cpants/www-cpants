package WWW::CPANTS::DB::Table::Distributions;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use WWW::CPANTS::Util::SQL;
use parent 'WWW::CPANTS::DB::Table';

sub columns ($self) { (
    [id                => '_sereal_'],
    [name              => '_dist_name_', unique => 1],
    [uids              => '_json_'],
    [latest_uid        => '_upload_id_'],
    [latest_stable_uid => '_upload_id_'],
    [latest_dev_uid    => '_upload_id_'],
    [first_uid         => '_upload_id_'],
    [first_released_at => '_epoch_'],
    [last_released_at  => '_epoch_'],
    [last_released_by  => '_pause_id_'],
    [rt                => '_json_'],
    [github            => '_json_'],
    [used_by           => '_json_'],
) }

sub iterate_name_and_uids ($self) {
    $self->iterate(qq[
    SELECT id, name, uids, latest_stable_uid, latest_dev_uid, last_released_at
    FROM distributions
  ]);
}

sub select_by_name ($self, $name) {
    my $sth = $self->{sth}{select_by_name} //= $self->prepare(qq[
    SELECT * FROM distributions
    WHERE name = ?
  ]);
    $self->select($sth, $name);
}

sub select_all_latest_uids_by_name ($self, $names) {
    my $quoted_names = $self->quote_and_concat($names);
    $self->select_all(qq[
    SELECT latest_stable_uid, latest_dev_uid FROM distributions
    WHERE name IN ($quoted_names)
    ORDER BY last_released_at DESC
  ]);
}

sub update_uids ($self, $info) {
    my @fields = qw/
        name uids latest_uid latest_stable_uid latest_dev_uid
        first_uid first_released_at last_released_at last_released_by
        /;
    if ($info->{id}) {
        my $sth = $self->{sth}{update_uid} //= do {
            my $placeholders = join ', ', map { "$_ = ?" } @fields;
            $self->prepare(qq[
        UPDATE distributions
        SET $placeholders
        WHERE id = ?
      ]);
        };
        $sth->execute(@$info{ @fields, 'id' });
    } else {
        my $sth = $self->{sth}{insert_uid} //= do {
            my $concat_fields = join ', ', @fields;
            my $placeholders  = substr('?,' x @fields, 0, -1);
            $self->prepare(qq[
        INSERT INTO distributions ($concat_fields)
        VALUES ($placeholders)
      ]);
        };
        $sth->execute(@$info{@fields});
    }
}

sub update_used_by ($self, $name, $map) {
    my $sth = $self->{sth}{update_used_by} //= $self->prepare(qq[
    UPDATE distributions SET used_by = ? WHERE name = ?
  ]);
    $sth->execute(encode_json($map), $name);
}

1;
