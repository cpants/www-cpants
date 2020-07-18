package WWW::CPANTS::Bin::Task::Maint::ShowStatus;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use parent 'WWW::CPANTS::Bin::Task';

sub run ($self, @args) {
    my $db = $self->db;

    my $job_queue = $db->table('JobQueue');
    for my $job (@{ $job_queue->select_all_running_jobs // [] }) {
        say sprintf "%s is running, started at %s (pid: %i)",
            $job->{name}, ymdhms($job->{started_at}), $job->{pid};
    }

    my $cpants_revision = WWW::CPANTS->context->cpants_revision;
    say "CPANTS revision: $cpants_revision";
    if (my $uploads_with_older_revisions = $db->table('Uploads')->count_older_revisions($cpants_revision)) {
        say "$uploads_with_older_revisions rows with older revisions";
    }

    my $queued = $db->table('Queue')->count;
    say "$queued rows in queue";
}

1;
