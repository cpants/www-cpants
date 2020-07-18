package WWW::CPANTS::Bin::Task::PostProcess::UpdateAuthorStats;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;

our @READ  = qw/Uploads/;
our @WRITE = qw/Authors/;

sub run ($self, @args) {
    my $db   = $self->db;
    my $rows = $db->table('Uploads')->select_release_stats;

    my $authors = $db->table('Authors');
    for my $row (@$rows) {
        my $pause_id = delete $row->{pause_id};
        $authors->update_release_stats($pause_id, $row);
    }
}

1;
