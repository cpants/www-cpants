package WWW::CPANTS::DB::Table::Distributions;

use Mojo::Base 'WWW::CPANTS::DB::Table', -signatures;
use WWW::CPANTS::Util::JSON qw/encode_json/;

sub columns ($self) { (
    [id                => '_serial_'],
    [name              => '_dist_name_', unique => 1],
    [uids              => '_json_'],
    [latest_uid        => '_upload_id_'],
    [latest_stable_uid => '_upload_id_'],
    [latest_dev_uid    => '_upload_id_'],
    [first_uid         => '_upload_id_'],
    [first_release_at  => '_epoch_'],
    [last_release_at   => '_epoch_'],
    [last_release_by   => '_pause_id_'],
    [rt                => '_json_'],
    [github            => '_json_'],
    [used_by           => '_json_'],
    [advisories        => '_json_'],
) }

sub iterate_name_and_uids ($self) {
    my $sql = <<~';';
    SELECT id, name, uids, latest_stable_uid, latest_dev_uid, last_release_at
    FROM distributions
    ;
    $self->iterate($sql);
}

sub select_by_name ($self, $name) {
    my $sql = <<~';';
    SELECT * FROM distributions WHERE name = ?
    ;
    $self->select($sql, $name);
}

sub select_all_latest_uids_by_name ($self, $names) {
    my $sql = <<~';';
    SELECT latest_stable_uid, latest_dev_uid FROM distributions
    WHERE name IN (:names)
    ORDER BY last_release_at DESC
    ;
    $self->select_all($sql, [names => $names]);
}

sub update_uids ($self, $info) {
    my @fields = qw(
        name uids latest_uid latest_stable_uid latest_dev_uid
        first_uid first_release_at last_release_at last_release_by
    );
    if ($info->{id}) {
        my $placeholders = join ',', map { "$_ = ?" } @fields;
        my $sql          = <<~";";
      UPDATE distributions
      SET $placeholders
      WHERE id = ?
      ;
        $self->update($sql, @$info{ @fields, 'id' });
    } else {
        my $concat_fields = join ',', @fields;
        my $placeholders  = substr('?,' x @fields, 0, -1);
        my $sql           = <<~";";
      INSERT INTO distributions ($concat_fields)
      VALUES ($placeholders)
      ;
        $self->insert($sql, @$info{@fields});
    }
}

sub update_used_by ($self, $name, $map) {
    my $sql = <<~';';
    UPDATE distributions SET used_by = ? WHERE name = ?
    ;
    $self->update($sql, encode_json($map), $name);
}

sub update_advisories ($self, $name, $advisories) {
    my $sql = <<~';';
    UPDATE distributions SET advisories = ? WHERE name = ?
    ;
    $self->update($sql, encode_json($advisories), $name);
}

1;
