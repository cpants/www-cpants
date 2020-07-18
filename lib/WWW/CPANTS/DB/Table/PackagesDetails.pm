package WWW::CPANTS::DB::Table::PackagesDetails;

use Mojo::Base 'WWW::CPANTS::DB::Table', -signatures;

sub columns ($self) { (
    [uid     => '_upload_id_'],
    [module  => '_module_name_'],
    [version => '_version_string_'],
    [path    => '_cpan_path_'],
    [dist    => '_dist_name_'],
) }

sub indices ($self) { (
    [qw/module/],
) }

sub select_all_by_modules ($self, $modules) {
    my $sql = <<~';';
    SELECT * FROM packages_details
    WHERE module IN (:modules)
    ;
    $self->select_all($sql, [modules => $modules]);
}

sub select_unique_dists_by_modules ($self, $modules) {
    my $sql = <<~';';
    SELECT DISTINCT(id), path FROM packages_details
    WHERE id IS NOT NULL AND module IN (:modules)
    ;
    $self->select_all($sql, [modules => $modules]);
}

1;
