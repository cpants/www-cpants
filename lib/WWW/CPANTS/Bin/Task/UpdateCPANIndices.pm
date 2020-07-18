package WWW::CPANTS::Bin::Task::UpdateCPANIndices;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;

has subtasks => \&_build_subtasks;

sub _build_subtasks ($self) {
    my @subtask_names = qw(
        PackagesDetails
        Permissions
        Whois
    );
    [map { $self->subtask("UpdateCPANIndices\::$_") } @subtask_names];
}

sub run ($self, @args) {
    $_->ctx($self->ctx)->run(@args) for $self->subtasks->@*;
}

1;
