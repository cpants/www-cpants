package WWW::CPANTS::Bin::Task::PostProcess;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;

has subtasks => \&_build_subtasks;

sub _build_subtasks ($self) {
    my @subtask_names = qw(
        UpdateAuthorStats
        UpdateSecurityAdvisories
        UpdateReverseDependency
        UpdateRanking
        UpdateCaches
    );
    [map { $self->subtask("PostProcess\::$_") } @subtask_names];
}

sub run ($self, @args) {
    $_->ctx($self->ctx)->run(@args) for $self->subtasks->@*;
}

1;
