package WWW::CPANTS::Bin::Task::AnalyzeAll;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::Parallel;

our @READ    = qw/Queue/;
our @WRITE   = qw/Queue/;
our @OPTIONS = (
    'workers=i',
    'timeout=i',
    'slows=i',
);

has 'task_id';
has 'max_per_process'  => 100;
has 'max_process_time' => 13 * 60;

sub subtasks ($self) {
    [$self->subtask('Analyze')];
}

sub run ($self, @args) {
    my $queue = $self->db->table('Queue');

    my $count;
    my $start = time;
    if (!$self->ctx->quiet) {
        $count = $queue->count;
        $self->log(info => "$count is queued");
        $self->timer->total($count);
    }
    my $should_end = $self->task_id ? $start + $self->max_process_time : 0;

    # preload indices
    $self->ctx->cpan->preload_indices;

    my $max_workers = $self->workers // 3;
    parallel(
        $max_workers,
        sub ($runner) {
            while ($queue->is_not_empty) {
                $runner->run(sub {
                    $0 =~ s/\(master\)/\(worker\)/;
                    my $inner_db    = $self->new_db;
                    my $inner_queue = $inner_db->table('Queue');
                    my $subtask     = $self->subtask('Analyze');
                    my $ct          = 0;
                    while (my $target = $inner_queue->next) {
                        my ($uid, $path) = @$target{qw/uid path/};
                        $subtask->analyze($uid, $path) or next;
                        $inner_queue->dequeue($uid)    or $self->log(warn => "Failed to dequeue $uid");
                        if (++$ct >= $self->max_per_process) {
                            if (!$self->ctx->quiet) {
                                my $left = $inner_queue->count;
                                my $done = $count - $left;
                                $self->timer->show_progress($done);
                            }
                            last;
                        }
                    }
                });
                last if $should_end and $should_end > time;
            }
        },
    );
}

1;
