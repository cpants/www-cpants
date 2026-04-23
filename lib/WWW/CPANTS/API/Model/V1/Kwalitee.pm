package WWW::CPANTS::API::Model::V1::Kwalitee;

use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Format qw(decimal);
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Model::Kwalitee;

sub load ($self, $params = {}) {
    my $pause_id = is_pause_id($params->{pause_id})
        or return $self->bad_request("'$params->{pause_id}' is not a valid pause id");

    my $db     = $self->db;
    my $author = $db->table('Authors')->select_by_pause_id($pause_id)            or return;
    my $dists  = $db->table('Kwalitee')->select_all_latest_for_author($pause_id) or return;

    my $info = {
        Average_Kwalitee     => decimal($author->{average_kwalitee}),
        CPANTS_Game_Kwalitee => decimal($author->{average_core_kwalitee}),
        Liga                 => $author->{cpan_dists} >= 5 ? '5 or more' : 'less than 5',
        Rank                 => $author->{rank},
    };

    my $metrics = WWW::CPANTS::Model::Kwalitee->new;

    my %distributions;
    for my $dist (@$dists) {
        my $name     = $dist->{distribution};
        my $kwalitee = decimal($dist->{kwalitee});
        my %details;
        for ($metrics->names->@*) {
            $details{$_} = $dist->{$_} ? 'ok' : 'opt_not_ok';
        }
        $distributions{$name} = {
            kwalitee => $kwalitee,
            details  => \%details,
        };
    }

    return {
        info          => $info,
        distributions => \%distributions,
    };
}

1;
