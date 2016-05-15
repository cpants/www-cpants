package WWW::CPANTS::Bin::Model::BackPAN;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;

sub new ($class, $root = config('backpan_dir')) {
  my $path = Path::Tiny::path($root);
  if (!-d $path->child('authors/id')) {
    carp "$path seems not a BackPAN mirror";
    return;
  }
  bless {path => $path}, $class;
}

sub child ($self, $path) { $self->{path}->child($path) }

sub author_dir ($self, $pause_id) {
  $self->child(join '/', "authors/id", substr($pause_id, 0, 1), substr($pause_id, 0, 2), $pause_id);
}

sub authors_id_dir ($self) {
  $self->child("authors/id");
}

1;
