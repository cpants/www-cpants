package WWW::CPANTS::Bin::Task;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use WWW::CPANTS::Util::JSON qw/slurp_json save_json/;
use WWW::CPANTS::Util::Loader qw/use_module/;
use WWW::CPANTS::Util::Datetime qw/strftime/;
use WWW::CPANTS::Model::TableGuard;
use WWW::CPANTS::Model::Timer;
use List::Util 1.45 qw/uniq/;

with qw(
    WWW::CPANTS::Role::Logger
    WWW::CPANTS::Role::Options
);

has 'ctx';
has 'name'  => \&_build_name;
has 'stash' => \&_build_stash;
has 'guard' => \&_build_guard;
has 'timer' => \&_build_timer;

sub _build_name ($self) {
    my $class = ref $self || $self;
    my ($name) = $class =~ /^WWW::CPANTS::Bin::Task::(.+)$/;
    $name;
}

sub _build_stash ($self) {
    my $name = $self->name;
    slurp_json("Task::$name") // {};
}

sub _build_guard ($self) {
    my $guard = WWW::CPANTS::Model::TableGuard->new;
    $guard->check($self->tables_to_write) or return;
    $guard;
}

sub _build_timer ($self) {
    WWW::CPANTS::Model::Timer->new(name => $self->name);
}

sub db ($self)      { $self->ctx->db }
sub new_db ($self)  { $self->ctx->new_db }
sub cpan ($self)    { $self->ctx->cpan }
sub backpan ($self) { $self->ctx->backpan }
sub force ($self)   { $self->ctx->force }
sub dry_run ($self) { $self->ctx->dry_run }

sub trace ($self, $value = undef) {
    if (defined $value) {
        $self->ctx->db->trace($value);
        return $self;
    }
    $self->ctx->db->trace;
}

sub tables_to_read ($self) {
    my $class = ref $self || $self;
    no strict 'refs';
    my @tables = @{"$class\::READ"};
    if ($self->can('subtasks')) {
        push @tables, map { $_->tables_to_read } $self->subtasks->@*;
    }
    uniq @tables;
}

sub tables_to_write ($self) {
    my $class = ref $self || $self;
    no strict 'refs';
    my @tables = @{"$class\::WRITE"};
    if ($self->can('subtasks')) {
        push @tables, map { $_->tables_to_write } $self->subtasks->@*;
    }
    uniq @tables;
}

sub check_tables ($self) {
    my $db = $self->db;
    my %seen;
    for my $name ($self->tables_to_read, $self->tables_to_write) {
        next if $seen{$name}++;
        my $table = $db->table($name);
        $table->is_setup or $table->setup;
    }
    $self->guard or return;
    return 1;
}

sub setup_tables ($self) {
    return unless WWW::CPANTS->is_testing;
    my %seen;
    for my $name ($self->tables_to_read, $self->tables_to_write) {
        next if $seen{$name}++;
        $self->db->table($name)->setup;
    }
}

sub subtask ($self, $name) {
    $self->ctx->load_task($name);
}

sub save_stash ($self) {
    return unless ref $self;
    my $name = $self->name;
    $self->stash->{last_executed} = time;
    save_json("Task::$name", $self->stash);
}

sub last_executed ($self) {
    my $last_executed = $self->stash->{last_executed} or return '';
    strftime('%Y-%m-%d %H:%M:%S', $last_executed);
}

sub status_line ($self) {
    my $status = $self->name;
    if (my $last_executed = $self->last_executed) {
        $status .= " [Last executed at $last_executed]";
    }
    $status;
}

sub DESTROY ($self) {
    $self->save_stash;
}

1;
