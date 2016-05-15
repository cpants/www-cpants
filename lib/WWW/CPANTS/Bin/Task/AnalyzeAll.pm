package WWW::CPANTS::Bin::Task::AnalyzeAll;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use WWW::CPANTS::Bin::Util::Parallel;
use parent 'WWW::CPANTS::Bin::Task';

my $MaxPerProcess = 100;
my $MaxProcessTime = 13 * 60;

sub option_specs {(
  ['workers=i', 'number of max workers'],
  ['show_diff|show-diff|diff', 'show diff'],
)}

sub run ($self, @args) {
  my $db = $self->db;
  $db->advisory_lock(qw/Analysis Queue Errors/) or return;
  my $queue = $db->table('Queue');

  my $count;
  my $start = time;
  if ($self->development_mode) {
    $count = $queue->count;
    log(info => "$count is queued");
  }
  my $should_end = $self->{job_id} ? $start + $MaxProcessTime : 0;

  my $cpan = $self->cpan;
  $cpan->fetch_permissions unless $cpan->has_permissions;

  my $max_workers = $self->option('workers') // 3;
  parallel($max_workers, sub ($runner) {
    while($queue->is_not_empty) {
      $runner->run(sub {
        $0 =~ s/\(master\)/\(worker\)/;
        my $inner_db = $self->new_db;
        my $inner_queue = $inner_db->table('Queue');
        my $task = $self->task('Analyze')->setup($inner_db);
        my $ct = 0;
        while(my $target = $inner_queue->next) {
          my ($uid, $path) = @$target{qw/uid path/};
          $task->analyze($uid, $path) or next;
          $inner_queue->dequeue($uid);
          if (++$ct >= $MaxPerProcess) {
            if ($self->development_mode) {
              my $left = $inner_queue->count;
              my $done = $count - $left;
              $self->show_progress($done, $count);
            }
            last;
          }
        }
      });
      last if $should_end and $should_end > time;
    }
  });
}

1;
