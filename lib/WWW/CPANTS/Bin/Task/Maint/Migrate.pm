package WWW::CPANTS::Bin::Task::Maint::Migrate;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;

sub run ($self, @args) {
    my $db = $self->db;
    for my $name ($db->table_names) {
        my $table = $db->table($name);
        next unless $table->is_setup;
        $table->migrate;
    }
}

1;
