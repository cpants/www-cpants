package WWW::CPANTS::Model::PidFile;

use Mojo::Base -base, -signatures;
use WWW::CPANTS::Util::Path;

has 'id'   => \&_id_is_required;
has 'file' => \&_build_file;
has 'pid'  => sub ($self) { $$ };

sub _id_is_required ($self) {
    Carp::confess "id is required";
}

sub _build_file ($self) {
    my $id = $self->id;
    cpants_path("tmp/pid/$id.pid");
}

sub exists ($self) {
    -f $self->file ? 1 : 0;
}

sub slurp ($self) {
    $self->exists ? $self->file->slurp : undef;
}

sub spew ($self, $pid) {
    $self->file->parent->mkpath;
    $self->file->spew($pid);
}

sub DESTROY ($self) {
    return unless $self->pid eq $$;
    my $pid = $self->slurp or return;
    $self->file->remove if $pid eq $self->pid;
}

1;
