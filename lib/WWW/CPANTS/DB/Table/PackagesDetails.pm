package WWW::CPANTS::DB::Table::PackagesDetails;

use WWW::CPANTS;
use WWW::CPANTS::Util::SQL;
use parent 'WWW::CPANTS::DB::Table';

sub columns ($self) {(
  [uid => '_upload_id_'],
  [module => '_module_name_'],
  [version => '_version_string_'],
  [path => '_cpan_path_'],
  [dist => '_dist_name_'],
)}

sub indices ($self) {(
  [qw/module/],
)}

sub select_all_by_modules ($self, $modules) {
  my $quoted_modules = $self->quote_and_concat($modules);
  $self->select_all(qq[
    SELECT * FROM packages_details
    WHERE module IN ($quoted_modules)
  ]);
}

sub select_unique_dists_by_modules ($self, $modules) {
  my $quoted_modules = $self->quote_and_concat($modules);
  $self->select_all(qq[
    SELECT DISTINCT(id), path FROM packages_details
    WHERE id IS NOT NULL AND module IN ($quoted_modules)
  ]);
}

1;
