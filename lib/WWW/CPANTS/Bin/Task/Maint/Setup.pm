package WWW::CPANTS::Bin::Task::Maint::Setup;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use parent 'WWW::CPANTS::Bin::Task';

sub run ($self, @args) {
  my $db = $self->db;
  for my $name ($db->table_names) {
    my $table = $db->table($name);
    # TODO: skip if it's already set up

    log(info => "setup $name");
    $table->setup;
    $table->migrate;
  }
}

1;
