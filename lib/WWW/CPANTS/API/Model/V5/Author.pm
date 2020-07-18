package WWW::CPANTS::API::Model::V5::Author;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Util::Datetime;
use WWW::CPANTS::Util::JSON;

with qw/WWW::CPANTS::Role::API::Model::V5::Author::Status/;

sub path_template ($self) { '/author/{pause_id}' }

sub operation ($self) {
    +{
        tags        => ['Author'],
        description => 'Returns CPAN author information',
        parameters  => [{
                description => 'PAUSE ID',
                in          => 'path',
                name        => 'pause_id',
                required    => json_true,
                schema      => { type => 'string' },
            },
        ],
        responses => {
            200 => {
                description => 'CPAN author information',
                content     => {
                    'application/json' => {
                        schema => {
                            type       => 'object',
                            properties => {},
                        },
                    },
                },
            },
        },
    };
}

sub _load ($self, $params = {}) {
    my $pause_id = is_pause_id($params->{pause_id})
        or return $self->bad_request("'$params->{pause_id}' is not a valid pause id");

    my ($status, $whois) = $self->check_whois_status($pause_id);
    return $whois unless $status;

    my $db     = $self->db;
    my $author = $db->table('Authors')->find($pause_id)
        or return $self->bad_request("'$pause_id' not found");

    $author->{$_} = $whois->{$_} for keys %$whois;

    my %converts = (
        last_release_at     => 'last_release_on',
        last_new_release_at => 'last_new_release_on',
        introduced          => 'joined_on',
    );

    for my $key (keys %converts) {
        $author->{ $converts{$key} } = $author->{$key} ? ymd($author->{$key}) : '-';
        delete $author->{$key};
    }

    if ($author->{json}) {
        $author->{extra} = decode_json($author->{json});
    }
    delete $author->{$_} for qw(
        json
        json_updated_at
        has_cpandir
    );

    $author;
}

1;
