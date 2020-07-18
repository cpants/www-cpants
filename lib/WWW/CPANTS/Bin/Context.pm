package WWW::CPANTS::Bin::Context;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use WWW::CPANTS;
use WWW::CPANTS::DB;
use WWW::CPANTS::Util::Loader;
use WWW::CPANTS::Model::CPAN;
use WWW::CPANTS::Model::Kwalitee;
use Path::Tiny ();

with qw(
    WWW::CPANTS::Role::Logger
    WWW::CPANTS::Role::Options
);

our @OPTIONS = (
    'dry_run|dry-run',
    'all',
    'force',
    'trace:1',
    'verbose|v',
);

has 'db'       => \&_build_db;
has 'cpan'     => \&_build_cpan;
has 'backpan'  => \&_build_backpan;
has 'quiet'    => \&_build_quiet;
has 'kwalitee' => \&_build_kwalitee;

sub _build_db ($self) {
    WWW::CPANTS::DB->new(trace => $self->trace);
}

sub _build_cpan ($self) {
    WWW::CPANTS::Model::CPAN->new(
        path => WWW::CPANTS->instance->cpan_path,
    );
}

sub _build_backpan ($self) {
    WWW::CPANTS::Model::CPAN->new(
        path => WWW::CPANTS->instance->backpan_path,
    );
}

sub _build_kwalitee ($self) {
    WWW::CPANTS::Model::Kwalitee->new;
}

sub _build_quiet ($self) {
    return if $self->verbose;
    WWW::CPANTS->instance->quiet;
}

sub new_db ($self) {
    $self->db(_build_db($self));
    $self->db;
}

sub load_task ($self, $name) {
    my $task_class = use_module("WWW::CPANTS::Bin::Task::$name");
    $task_class->new(name => $name, ctx => $self);
}

sub task_names ($self) {
    my @names = sort keys submodules("WWW::CPANTS::Bin::Task")->%*;
    \@names;
}

1;
