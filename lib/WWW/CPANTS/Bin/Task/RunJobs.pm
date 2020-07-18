package WWW::CPANTS::Bin::Task::RunJobs;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use WWW::CPANTS::Bin::Util::Parallel;
use parent 'WWW::CPANTS::Bin::Task';

sub run ($self, @args) {
    my $max_workers = 1;
    parallel(
        $max_workers,
        sub ($runner) {
            my $queue = $self->db->table('JobQueue');
            while (my $job = $queue->next) {
                $runner->run(sub {
                    $0 =~ s/\(master\)/\(worker\)/;
                    my $task = $self->task($job->{name});
                    $task->{job_id} = $job->{id};
                    my @args = defined $job->{args} ? $job->{args} : ();
                    $task->run_and_log(@args);
                    $queue->dequeue($job->{id});
                });
            }
        });
}

1;
