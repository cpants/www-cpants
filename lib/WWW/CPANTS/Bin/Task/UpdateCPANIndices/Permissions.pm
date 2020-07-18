package WWW::CPANTS::Bin::Task::UpdateCPANIndices::Permissions;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use Syntax::Keyword::Try;

our @WRITE = qw/Permissions/;

sub run ($self, @args) {
    my $table = $self->db->table('Permissions');

    $self->log(info => "updating permissions");

    try {
        my $txn = $table->txn;
        $table->truncate;
        $table->bulk_insert($self->cpan->perms->list);
        $txn->commit;
    } catch {
        $self->log(error => $@)
    }

    $self->log(info => "updated permissions");
}

1;
