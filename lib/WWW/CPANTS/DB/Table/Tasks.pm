package WWW::CPANTS::DB::Table::Tasks;

use Mojo::Base 'WWW::CPANTS::DB::Table', -signatures;

sub columns ($self) { (
    [id         => '_serial_'],
    [name       => 'varchar(255)', unique => 1],
    [priority   => 'tinyint', default => 0],
    [pid        => 'smallint', default => 0],
    [created_at => '_epoch_'],
    [started_at => '_epoch_'],
) }

sub indices ($self) { (
    ['priority desc', 'id'],
) }

sub is_not_empty ($self) {
    my $sql = <<~';';
    SELECT 1 FROM tasks
    WHERE pid = 0
    LIMIT 1
    ;
    $self->select_col($sql);
}

sub count ($self) {
    my $sql = <<~';';
    SELECT COUNT(id) FROM queue
    WHERE pid = 0
    ;
    $self->select_col($sql);
}

sub next ($self) {
    my $updater = <<~';';
    UPDATE tasks SET pid = ?, started_at = ?
    WHERE id = (:id)
    ;
    my $selector = <<~';';
    SELECT id FROM tasks
    WHERE pid = 0
    ORDER BY priority DESC, id ASC
    LIMIT 1
    ;
    my $rowid = $self->update_and_get_updated_rowid($updater, $selector, $$, time);

    my $sql = <<~';';
    SELECT id, name FROM tasks WHERE id = ?
    ;
    $self->select($sql, $rowid);
}

sub remove ($self, $id) {
    my $sql = <<~';';
    DELETE FROM tasks WHERE id = ? AND pid = ?
    ;
    $self->delete($sql, $id, $$);
}

sub force_remove ($self, $id) {
    my $sql = <<~';';
    DELETE FROM tasks WHERE id = ?
    ;
    $self->delete($sql, $id);
}

sub select_all_running_tasks ($self) {
    my $sql = <<~';';
    SELECT * FROM tasks WHERE pid > 0
    ;
    $self->select_all($sql);
}

sub select_all_waiting_tasks ($self) {
    my $sql = <<~';';
    SELECT * FROM tasks WHERE pid = 0
    ;
    $self->select_all($sql);
}

1;
