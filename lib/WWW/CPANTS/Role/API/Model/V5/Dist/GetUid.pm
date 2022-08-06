package WWW::CPANTS::Role::API::Model::V5::Dist::GetUid;

use Mojo::Base -role, -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Util::Distname;
use WWW::CPANTS::Util::JSON;

sub get_uid ($self, $params) {
    my $author = $params->{pause_id};
    my $name   = $params->{name};

    my $db            = $self->db;
    my $distributions = $db->table('Distributions');

    my ($uid, $dist);
    if ($author) {
        my $name_version = $name;
        ($name, my $version) = distname_info($name_version);
        return $self->bad_request("'$author' seems not a pause id")                unless is_pause_id($author);
        return $self->bad_request("name contains weird characters: $name_version") unless is_alphanum($name);
        $dist = $distributions->select_by_name($name) or return $self->bad_request("$author/$name_version not found");
        my $uids = decode_json($dist->{uids});
        if (defined(is_alphanum($version))) {
            for my $info (@$uids) {
                if ($info->{version} eq $version and $info->{author} eq $author) {
                    $uid = $info->{uid};
                    last;
                }
            }
        } else {
            $uid = $dist->{latest_stable_uid} // $dist->{latest_dev_uid};
        }
        return $self->bad_request("$author/$name_version not found") unless $uid;
    } elsif (is_dist($name)) {
        $dist = $distributions->select_by_name($name) or return $self->bad_request("$name not found");
        my $uids = decode_json($dist->{uids});
        $uid = $dist->{latest_stable_uid} // $dist->{latest_dev_uid};
        return $self->bad_request("$name not found") unless $uid;
    } else {
        return $self->bad_request("unknown path: " . Data::Dump::dump($params));
    }

    wantarray ? ($uid, $dist) : $uid;
}

1;
