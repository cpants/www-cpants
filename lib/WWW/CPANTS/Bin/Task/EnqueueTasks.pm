package WWW::CPANTS::Bin::Task::EnqueueTasks;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;

our @READ  = qw/Tasks/;
our @WRITE = qw/Tasks/;

sub run ($self, @args) {
    return unless @args;

    my @rows = map {
        +{
            name       => $_,
            created_at => time,
            pid        => 0,
        }
    } @args;

    my $table = $self->db->table('Tasks');

    for my $task (@{ $table->select_all_running_tasks // [] }) {
        my $pid = $task->{pid};
        next if kill 0, $pid;
        $self->log(warn => "deleting $task->{name} from queue (pid $pid is gone)");
        $table->force_remove($task->{id});
    }

    $table->bulk_insert(\@rows, { ignore => 1 });
}

1;
