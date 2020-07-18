package WWW::CPANTS::Bin::Task::Enqueue;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::Distname;
use WWW::CPANTS::Util::PathUid;
use WWW::CPANTS::Model::Revision;

our @READ  = qw/Queue Analysis/;
our @WRITE = qw/Queue/;

sub run ($self, @args) {
    if (@args) {
        $self->enqueue_from_args(@args);
    } else {
        $self->enqueue_from_db;
    }
}

sub enqueue_from_args ($self, @paths) {
    my @rows;
    for my $path (@paths) {
        next unless defined $path and $path ne '';
        my $info = valid_distinfo($path);
        if (!$info) {
            $self->log(warn => "$path seems not a CPAN distribution");
            next;
        }
        my $cpan_path = $info->{path};
        my $uid       = path_uid($cpan_path);
        push @rows, {
            uid        => $uid,
            path       => $cpan_path,
            created_at => time,
            priority   => 100,
            released   => time,
            pid        => 0,
        };
        $self->log(debug => "enqueuing $cpan_path");
    }
    $self->db->table('Queue')->bulk_insert(\@rows, { ignore => 1 });
}

sub enqueue_from_db ($self) {
    my $db = $self->db;

    $self->delete_aborted_paths;

    my $revision = WWW::CPANTS::Model::Revision->new->id;
    $revision++ if $self->force;

    my @rows;
    my $iter = $db->table('Analysis')->iterate_rows_with_older_revision($revision);
    while (my $row = $iter->next) {
        my %item = (
            uid        => $row->{uid},
            path       => $row->{path},
            released   => $row->{released},
            created_at => time,
            priority   => 10,
            suspended  => 0,
            pid        => 0,
        );

        # Higher priority for distributions that are never analyzed
        $item{priority} = 100 unless $row->{cpants_revision};

        # Special case for Net::FullAuto, which takes much more
        # time to find dependencies (and is released too often)
        if ($row->{path} =~ m!/REEDFISH/Net\-FullAuto\-!) {
            $item{priority}  = 0;
            $item{suspended} = 1;
        }
        push @rows, \%item;
        $self->log(debug => "enqueuing $row->{path}");
    }
    $self->db->table('Queue')->bulk_insert(\@rows, { ignore => 1 });

    $self->unsuspend_some;
}

sub delete_aborted_paths ($self) {
    my $table = $self->db->table('Queue');
    my $pids  = $table->select_unfinished_pids;
    return unless $pids and @$pids;

    for my $pid (@$pids) {
        next if kill 0, $pid;
        my $paths = $table->select_paths_by_pid($pid);
        next unless $paths and @$paths;
        $self->log(warn => "deleting $_ from queue (pid $pid is gone)") for @$paths;
        $table->delete_by_pid($pid);
    }
}

sub unsuspend_some ($self) {
    my $table = $self->db->table('Queue');
    my $uids  = $table->select_suspended_uids;
    return unless $uids and @$uids;

    $table->unsuspend_by_uids($uids);
}

1;
