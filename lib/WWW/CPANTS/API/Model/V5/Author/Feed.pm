package WWW::CPANTS::API::Model::V5::Author::Feed;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::API::Util::Format;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Util::Datetime;
use HTTP::Status qw/HTTP_GONE/;

with qw/WWW::CPANTS::Role::API::Model::V5::Author::Status/;

sub _load ($self, $params) {
    my $pause_id = is_pause_id($params->{pause_id})
        or return $self->bad_request("'$params->{pause_id}' is not a valid pause id");

    $self->check_whois_status($pause_id)
        or return $self->bad_request("'$pause_id' is deleted", HTTP_GONE);

    my $db           = $self->db;
    my $releases     = $db->table('Uploads')->select_recent_by_author($pause_id);
    my @uids         = map { $_->{uid} } @$releases;
    my %kwalitee_map = map { $_->{uid} => $_ } @{ $db->table('Kwalitee')->select_all_by_uids(\@uids) // [] };

    my %feed_data = (
        title   => "CPANTS Feed for $pause_id",
        author  => "CPANTS",
        updated => datetime(@$releases ? $releases->[0]{released} : time),
    );

    my @entries;
    for my $release (@$releases) {
        my $name_version = ($release->{name} // '') . '-' . ($release->{version});
        my $kwalitee     = $kwalitee_map{ $release->{uid} };
        my $fails        = $self->ctx->kwalitee->failing_core_metrics($kwalitee);
        my $summary      = "Kwalitee: " . kwalitee_score($kwalitee->{core_kwalitee});
        $summary .= "; Core Fails: " . join ", ", @$fails if @$fails;
        push @entries, {
            title   => $name_version,
            link    => "/release/" . $release->{author} . "/" . $name_version,
            id      => $name_version,
            summary => $summary,
            updated => datetime($release->{released}),
        };
    }
    return {
        feed    => \%feed_data,
        entries => \@entries,
    };
}

1;
