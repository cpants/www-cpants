package WWW::CPANTS::Bin::Task::Maint::Setup;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;

sub run ($self, @args) {
    my $db = $self->db;
    for my $name ($db->table_names) {
        my $table = $db->table($name);
        if ($table->is_setup) {
            $self->log(debug => "$name is ready");
            next;
        }

        $self->log(info => "setup $name");
        $table->setup;
        $table->migrate;
    }
}

1;
