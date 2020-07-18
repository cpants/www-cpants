package WWW::CPANTS::Bin::Task::Maint::CheckZeroKwalitee;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use parent 'WWW::CPANTS::Bin::Task';

sub run ($self, @args) {
    my $db       = $self->db;
    my $kwalitee = $db->table('Kwalitee');

    # Kwalitee score 0 is a bad sign if it's not from the extractable failure
    for my $row (@{ $kwalitee->select_all_zero_kwalitee // [] }) {
        if ($row->{extractable}) {
            log(warn => "kwalitee for $row->{uid} [$row->{pause_id}] is zero");
        }
    }
}

1;
