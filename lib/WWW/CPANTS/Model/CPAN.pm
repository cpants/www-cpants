package WWW::CPANTS::Model::CPAN;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use Path::Tiny ();

has 'path' => \&_path_is_required;
has 'root' => \&_build_root;

with qw(
    WWW::CPANTS::Role::CPAN::Indices
    WWW::CPANTS::Role::CPAN::Path
);

sub _path_is_required ($self) {
    Carp::confess "path is required";
}

sub _build_root ($self) {
    my $root = Path::Tiny::path($self->path);
    Carp::croak "$root does not exist"          unless -d $root;
    Carp::croak "$root seems not a CPAN mirror" unless -d $root->child("authors/id");
    $root;
}

sub preload_indices ($self) {
    $_->preload for $self->indices->@*;
}

1;
