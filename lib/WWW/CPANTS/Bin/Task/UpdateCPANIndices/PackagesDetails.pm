package WWW::CPANTS::Bin::Task::UpdateCPANIndices::PackagesDetails;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use Syntax::Keyword::Try;

our @WRITE = qw/PackagesDetails/;

sub run ($self, @args) {
    my $table = $self->db->table('PackagesDetails');

    $self->log(info => "updating packages.details");

    try {
        my $txn = $table->txn;
        $table->truncate;
        $table->bulk_insert($self->cpan->packages->list);
        $txn->commit;
    } catch {
        $self->log(error => $@)
    }

    $self->log(info => "updated packages.details");
}

1;
