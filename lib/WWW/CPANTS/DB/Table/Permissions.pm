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

1;
