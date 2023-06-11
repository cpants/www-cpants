package WWW::CPANTS::Bin::Runner;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use Path::Tiny ();
use Syntax::Keyword::Try;
use WWW::CPANTS;
use WWW::CPANTS::Bin::Context;
use WWW::CPANTS::Util::Loader;
use WWW::CPANTS::Util::Path;
use WWW::CPANTS::Model::Timer;
use WWW::CPANTS::Model::PidFile;

with qw(
    WWW::CPANTS::Role::Logger
    WWW::CPANTS::Role::Options
);

our @OPTIONS = (
    'help|h',
);

has 'id'    => \&_build_id;
has 'ctx'   => \&_build_ctx;
has 'timer' => \&_build_timer;

sub _build_id ($self) {
    my $path = $FindBin::RealScript or return 'unknown';
    my $id   = Path::Tiny::path($path)->relative(WWW::CPANTS->instance->app_root)->stringify;
    $id =~ s/\W+/_/gr;
}

sub _build_ctx ($self) {
    WWW::CPANTS::Bin::Context->new;
}

sub _build_timer ($self) {
    WWW::CPANTS::Model::Timer->new(name => $self->id);
}

sub run_tasks ($self, @task_names) {
    local $ENV{LANG} = 'C';

    if (!@task_names) {
        my $task = $self->find_task_from_argv or return;
        @task_names = ($task);
    }

    my @args;
    if ($task_names[0] eq 'EnqueueTasks') {
        @args = splice @task_names, 1;
    }

    my $tasks = $self->load_tasks(\@task_names);

    return $self->show_help if $self->help;

    if (WWW::CPANTS->instance->is_under_maintenance and !$self->ctx->force and grep !/^Maint::/, @task_names) {
        print STDERR "under maintenance; use --force to run";
        return;
    }

    push @args, @ARGV;

    my $pidfile = $self->create_pidfile or return;
    $self->timer->start;
    local $ENV{CPANTS_RUNNER_STARTED_AT} = $self->timer->started_at;
    try {
        while (my $task = shift @$tasks) {
            $task->check_tables or next;
            $task->timer->start;
            $task->run(@args);
        }
    } catch {
        my $error = $@;
        $self->log(error => $error);
        return;
    }
    return 1;
}

sub load_tasks ($self, $names) {
    my @tasks;
    for my $name (@$names) {
        push @tasks, $self->ctx->load_task($name);
    }
    return \@tasks;
}

sub find_task_from_argv ($self) {
    my @task_names = $self->ctx->task_names->@*;
    my %map        = map { $_ => 1 } @task_names;
    for my $i (0 .. @ARGV - 1) {
        my $arg = $ARGV[$i];
        if ($map{$arg}) {
            splice @ARGV, $i, 1;
            return $arg;
        }
    }

    say "available tasks:";
    for my $name (@task_names) {
        my $task = $self->ctx->load_task($name);
        say " - " . $task->status_line;
    }
}

sub create_pidfile($self) {
    my $id   = $self->id;
    my $file = WWW::CPANTS::Model::PidFile->new(id => $id);
    if ($file->exists and !$self->ctx->force) {
        my $pid = $file->slurp;
        if (kill 0, $pid) {
            $self->log(info => "Another $id ($pid) is running");
            return;
        }

        # Clear remnant guard files
        require WWW::CPANTS::Model::TableGuard;
        my $guard_dir = WWW::CPANTS::Model::TableGuard->new->dir;
        for my $guard ($guard_dir->children) {
            next unless -f $guard;
            my $guard_pid = $guard->slurp;
            if ($pid eq $guard_pid) {
                $guard->remove;
            }
        }
    }
    $file->spew($$);
    $file;
}

1;
