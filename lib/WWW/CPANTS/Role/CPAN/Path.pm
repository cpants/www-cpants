package WWW::CPANTS::Role::CPAN::Path;

use Mojo::Base -role, -signatures;

sub child ($self, $path) { $self->root->child($path) }

sub distribution ($self, $path) {
    $self->child("authors/id/$path");
}

sub author_dir ($self, $pause_id) {
    my $path = join "/", substr($pause_id, 0, 1), substr($pause_id, 0, 2), $pause_id;
    my $dir  = $self->child("authors/id/$path");
    return unless -d $dir;
    $dir;
}

sub author_dir_iterator ($self, $pause_id) {
    my $dir = $self->author_dir($pause_id) or return;
    $dir->iterator({ recurse => 1, follow_symlinks => 0 });
}

1;
