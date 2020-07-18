package WWW::CPANTS::DB::Table::AcmeModules;

use Mojo::Base 'WWW::CPANTS::DB::Table', -signatures;

sub columns ($self) { (
    [module_id  => '_acme_id_', primary => 1],
    [module     => '_module_name_'],
    [version    => '_version_string_'],
    [released   => '_epoch_'],
    [authors    => 'integer'],
    [updated_at => '_epoch_'],
) }

sub indices ($self) { ({ unique => 1, columns => [qw/module/] }) }

sub has_module_id ($self, $module_id) {
    my $sql = <<~';';
    SELECT 1 FROM acme_modules WHERE module_id = ?
    ;
    $self->select_col($sql, $module_id);
}

sub insert_module ($self, $module_id, $module, $version, $released, $authors, $mtime) {
    my $sql = <<~';';
    INSERT INTO acme_modules (module_id, module, version, released, authors, updated_at)
    VALUES (?, ?, ?, ?, ?, ?)
    ;
    $self->do($sql, $module_id, $module, $version, $released, $authors, $mtime);
}

sub update_module ($self, $module_id, $module, $version, $released, $authors, $mtime) {
    my $sql = <<~';';
    UPDATE acme_modules
    SET version = ?, released = ?, authors = ?, updated_at = ?
    WHERE module_id = ?
    ;
    $self->do($sql, $version, $released, $authors, $mtime, $module_id);
}

sub remove_by_module_id ($self, $module_id) {
    my $sql = <<~';';
    DELETE FROM acme_modules WHERE module_id = ?
    ;
    $self->do($sql, $module_id);
}

sub select_modules ($self) {
    my $sql = <<~';';
    SELECT module_id, module, version, released, authors FROM acme_modules;
    ;
    $self->select_all($sql);
}

1;
