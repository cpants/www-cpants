package WWW::CPANTS::Bin::Task::PostProcess::UpdateAuthorStats;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;

our @READ  = qw/Uploads/;
our @WRITE = qw/Authors/;

sub run ($self, @args) {
    $self->_update_release_stats;
    $self->_update_last_analyzed_at;
}

sub _update_release_stats ($self) {
    my $db      = $self->db;
    my $authors = $db->table('Authors');

    my $rows = $db->table('Uploads')->select_release_stats;
    for my $row (@$rows) {
        my $pause_id = delete $row->{pause_id};
        $authors->update_release_stats($pause_id, $row);
    }
}

sub _update_last_analyzed_at ($self) {
    my $db      = $self->db;
    my $authors = $db->table('Authors');

    my $started_at = $ENV{CPANTS_RUNNER_STARTED_AT} // 0;
    my $rows       = $db->table('Analysis')->select_last_analyzed_at_since($started_at);
    for my $row (@$rows) {
        my $pause_id = delete $row->{author};
        $authors->update_last_analyzed_at($pause_id, $row->{last_analyzed_at});
    }
}

1;
