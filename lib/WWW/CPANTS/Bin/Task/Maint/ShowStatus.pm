package WWW::CPANTS::Bin::Task::Maint::ShowStatus;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::Datetime;
use WWW::CPANTS::Model::Revision;

has 'revision' => \&_build_revision;

sub _build_revision ($self) {
    WWW::CPANTS::Model::Revision->new;
}

sub run ($self, @args) {
    $self->show_task_status;
    $self->show_cpants_revision;
    $self->show_queue_status;
}

sub show_task_status ($self) {
    my $table = $self->db->table('Tasks');
    return unless $table->is_setup;

    for my $task (@{ $table->select_all_running_tasks // [] }) {
        say sprintf "%s is running, started at %s (pid: %i)",
            $task->{name}, ymdhms($task->{started_at}), $task->{pid};
    }
    for my $task (@{ $table->select_all_waiting_tasks // [] }) {
        say sprintf "%s is waiting, created at %s",
            $task->{name}, ymdhms($task->{created_at});
    }
}

sub show_cpants_revision ($self) {
    my $cpants_revision = $self->revision->id;
    say "CPANTS revision: $cpants_revision";

    my $table = $self->db->table('Analysis');
    return unless $table->is_setup;

    if (my $uploads_with_older_revisions = $table->count_older_revisions($cpants_revision)) {
        say "$uploads_with_older_revisions rows with older revisions";
    }
}

sub show_queue_status ($self) {
    my $table = $self->db->table('Queue');
    return unless $table->is_setup;

    my $queued = $table->count;
    say "$queued rows in queue";
}

1;
