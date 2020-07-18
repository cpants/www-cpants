package WWW::CPANTS::DB::Table::AcmeAuthors;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::DB::Table', -signatures;
use Syntax::Keyword::Try;

with qw/WWW::CPANTS::Role::Logger/;

sub columns ($self) { (
    [module_id => '_acme_id_'],
    [pause_id  => '_pause_id_'],
) }

sub indices ($self) { ({ unique => 1, columns => [qw/module_id pause_id/] }) }

sub insert_for_module_id ($self, $module_id, $authors) {
    my $sql = <<~';';
    INSERT INTO acme_authors (module_id, pause_id) VALUES (?, ?);
    ;
    my @rows = map { [$module_id, $_] } @$authors;
    my $sth  = $self->prepare($sql);
    my $txn  = $self->txn;
    try {
        $sth->execute(@$_) for @rows;
        $txn->commit;
    } catch {
        my $error = $@;
        $self->log(error => $error);
        $txn->rollback;
    }
}

sub remove_by_module_id ($self, $module_id) {
    my $sql = <<~';';
    DELETE FROM acme_authors WHERE module_id = ?
    ;
    $self->do($sql, $module_id);
}

sub select_authors_by_module_id ($self, $module_id) {
    my $sql = <<~';';
    SELECT pause_id FROM acme_authors WHERE module_id = ?
    ;
    $self->select_all_col($sql, $module_id);
}

sub select_module_ids_by_pause_id ($self, $pause_id) {
    my $sql = <<~';';
    SELECT module_id FROM acme_authors WHERE pause_id = ?
    ;
    $self->select_all_col($sql, $pause_id);
}

1;
