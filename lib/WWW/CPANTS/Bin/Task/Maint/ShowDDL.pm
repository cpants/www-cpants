package WWW::CPANTS::Bin::Task::Maint::ShowDDL;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;

our @OPTIONS = (
    'table=s',
);

sub run ($self, @args) {
    my $table = $self->table or return;
    say $self->db->table($table)->schema;
}

1;
