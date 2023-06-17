package WWW::CPANTS::API::Model::V5::Dist::Common;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::API::Util::Format;
use WWW::CPANTS::Util::Distname;
use WWW::CPANTS::Util::JSON;

with qw/WWW::CPANTS::Role::API::Model::V5::Dist::GetUid/;

sub _load ($self, $params = {}) {
    my ($uid, $dist) = $self->get_uid($params);
    return unless $uid;

    my $db      = $self->db;
    my $release = $db->table('Uploads')->select_by_uid($uid)
        or return $self->internal_error("uid($uid) not found");

    $dist->{$_} //= $release->{$_} for keys %$release;
    $dist->{latest}       = 1 if $uid eq $dist->{latest_uid};
    $dist->{name_version} = join '-', $dist->{name}, $dist->{version};

    $dist->{recent_releases} = decode_json($dist->{uids});

    if ($dist->{advisories}) {
        my $advisories = decode_json($dist->{advisories});
        my @affected_advisories;
        my $version = $dist->{version} // '';
        for my $advisory (@$advisories) {
            if (grep { $_ eq $version } @{ $advisory->{affected_version_list} // [] }) {
                push @affected_advisories, $advisory;
            }
        }
        $dist->{affected_advisories} = \@affected_advisories;
    }

    my $kwalitee = $db->table('Kwalitee')->select_scores_by_uid($uid);
    $dist->{core_kwalitee} = kwalitee_score($kwalitee->{core_kwalitee});
    $dist->{kwalitee}      = kwalitee_score($kwalitee->{kwalitee});

    my $resources = $db->table('Resources')->select_by_uid($uid);
    if ($resources) {
        $dist->{repository_url} = $resources->{repository_url};
        $dist->{bugtracker_url} = $resources->{bugtracker_url};
        $dist->{resources}      = decode_json($resources->{resources}) if $resources->{resources};
    }

    my $analysis = $db->table('Analysis')->select_by_uid($uid);
    if ($analysis) {
        $dist->{last_analyzed_at} = $analysis->{last_analyzed_at};
    }

    $dist;
}

1;
