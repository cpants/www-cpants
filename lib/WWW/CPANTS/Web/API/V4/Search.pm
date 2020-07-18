package WWW::CPANTS::Web::API::V4::Search;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use parent 'WWW::CPANTS::Web::Data';

sub load ($self, $params = {}) {
    my $name = is_alphanum($params->{name}) or return {
        authors => [],
        dists   => [],
    };

    my $db   = $self->db;
    my $rows = $db->table('Uploads')->search_for($name);

    my (@authors, @dists);
    for my $row (@$rows) {
        if ($row->{author}) {
            push @authors, $row->{author};
        }
        if ($row->{name}) {
            push @dists, $row->{name};
        }
    }

    return {
        authors => \@authors,
        dists   => \@dists,
    };
}

1;
