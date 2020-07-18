package WWW::CPANTS::Web::Page::Recent;

use WWW::CPANTS;
use parent 'WWW::CPANTS::Web::Data';

sub data ($self, @args) {
    my $db       = $self->db;
    my $table    = $db->table('Uploads');
    my $releases = $table->select_all_recent_releases;
    my $total    = $table->count_recent_releases;

    return {
        total => $total,
        data  => {
            releases => $releases,
        },
    };
}

1;
