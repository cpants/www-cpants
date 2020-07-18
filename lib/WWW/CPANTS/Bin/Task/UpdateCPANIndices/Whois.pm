package WWW::CPANTS::Bin::Task::UpdateCPANIndices::Whois;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use Syntax::Keyword::Try;

our @WRITE = qw/Authors Whois/;

sub run ($self, @args) {
    $self->log(info => "updating whois");
    $self->update_whois;
    $self->update_authors;
    $self->log(info => "updated whois");
}

sub update_whois ($self) {
    my $table = $self->db->table('Whois');

    try {
        my $txn = $table->txn;
        $table->truncate;
        $table->bulk_insert($self->cpan->whois->list);
        $txn->commit;
    } catch {
        $self->log(error => $@)
    }
}

sub update_authors ($self, @args) {
    my $table = $self->db->table('Authors');

    $table->bulk_insert($self->cpan->whois->list, { ignore => 1 });
}

1;
