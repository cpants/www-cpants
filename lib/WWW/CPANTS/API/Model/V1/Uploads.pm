package WWW::CPANTS::API::Model::V1::Uploads;

use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;

sub load ($self, $params = {}) {
    my @distv = ref $params->{d} eq 'ARRAY' ? $params->{d}->@* : $params->{d};

    my $db = $self->db;
    my @rows;
    for my $d (@distv) {
        my ($name, $version) = split ',', $d;
        next unless is_dist($name);
        if ($version) {
            next unless is_alphanum($version);
        }
        my $path = $db->table('Uploads')->select_distv($name, $version) or next;
        my ($author, $filename) = $path =~ m!^[A-Z]/[A-Z0-9]{2}/([^/]+)/(.+)$!;
        push @rows, {
            author   => $author,
            filename => $filename,
        };
    }
    return \@rows;
}

1;
