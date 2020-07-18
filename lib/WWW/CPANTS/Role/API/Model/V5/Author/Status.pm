package WWW::CPANTS::Role::API::Model::V5::Author::Status;

use Mojo::Base -role, -signatures;

sub check_whois_status ($self, $pause_id) {
    my $db    = $self->db;
    my $whois = $db->table('Whois')->find($pause_id) or return $self->bad_request("'$pause_id' not found");

    # Do not expose deleted user's information
    if ($whois->{deleted}) {
        return unless wantarray;
        return (undef, { pause_id => $pause_id, deleted => 1 });
    }

    # Hide spammers too
    if ($whois->{nologin} and !$whois->{system}) {
        return unless wantarray;
        return (undef, { pause_id => $pause_id, banned => 1 });
    }

    return 1 unless wantarray;
    return (1, $whois);
}

1;
