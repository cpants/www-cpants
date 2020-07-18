package WWW::CPANTS::Bin::Task::RunTasks;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;

our @READS  = qw/Tasks/;
our @WRITES = qw/Tasks/;

sub run ($self, @args) {
    my $tasks = $self->db->table('Tasks');
    while (my $task_info = $tasks->next) {
        my $subtask = $self->subtask($task_info->{name});
        $subtask->run;
        $tasks->remove($task_info->{id});
    }
}

1;
