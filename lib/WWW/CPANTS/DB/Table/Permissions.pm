package WWW::CPANTS::DB::Table::Permissions;

use Mojo::Base 'WWW::CPANTS::DB::Table', -signatures;

sub columns ($self) { (
    [module   => '_module_name_'],
    [pause_id => '_pause_id_'],
    [type     => 'varchar(1)'],
) }

sub indices ($self) { (
    [qw/pause_id/],
    [qw/module/],
) }

sub select_all_by_author ($self, $pause_id) {
    my $sql = <<~';';
    SELECT * FROM permissions
    WHERE pause_id = ?
    ;
    $self->select_all($sql, $pause_id);
}

sub select_unauthorized_modules_for_author ($self, $pause_id, $modules) {
    my $sql = <<~';';
    SELECT module FROM (
      SELECT module FROM permissions WHERE module IN (:modules) GROUP BY module
    )
    WHERE module NOT IN (SELECT module FROM permissions WHERE pause_id = ? GROUP BY module)
    GROUP BY module
    ;
    $self->select_all($sql, $pause_id, [modules => $modules]);
}

1;
