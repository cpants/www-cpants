package WWW::CPANTS::Bin::Task::EnqueueJobs;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use parent 'WWW::CPANTS::Bin::Task';

sub option_specs { (
    ['jobs|j=s', 'job names'],
) }

sub run ($self, @args) {
    my @jobs;
    if (my $job_names = $self->option('jobs')) {
        @jobs = map { +{ name => $_ } } split ',', $job_names;
    } else {
        for my $job (@{ $self->args->{jobs} // [] }) {
            if (!ref $job) {
                push @jobs, { name => $job };
            } else {
                push @jobs, { name => $job->[0], args => $job->[1] };
            }
        }
    }
    return unless @jobs;

    my $db    = $self->db;
    my $queue = $db->table('JobQueue');

    for my $job (@{ $queue->select_all_running_jobs // [] }) {
        my $pid = $job->{pid};
        if (!kill 0, $pid) {
            $queue->force_dequeue($job->{id});
        }
    }

    $queue->bulk_insert(\@jobs, { ignore => 1 });
}

1;
