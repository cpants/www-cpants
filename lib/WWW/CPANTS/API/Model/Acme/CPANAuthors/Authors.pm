package WWW::CPANTS::API::Model::Acme::CPANAuthors::Authors;

use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::API::Util::Format;
use WWW::CPANTS::Util::Datetime;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS;
use Encode;

sub path_template ($self) { '/cpan_authors/{module_id}/authors' }

sub operation ($self) {
    +{
        description => 'Returns a list of Acme::CPANAuthors modules',
        parameters  => [{
            description => 'Module ID',
            in          => 'path',
            name        => 'module_id',
            required    => json_true,
            schema      => { type => 'string' },
        }],
        responses => {
            200 => {
                description => 'A list of Acme::CPANAuthors modules with valid authors',
                content     => {
                    'application/json' => {
                        schema => {
                            type       => 'object',
                            properties => {
                                recordsTotal => { type => 'integer' },
                                data         => {
                                    type  => 'array',
                                    items => {
                                        type       => 'object',
                                        properties => {
                                            pause_id             => { type => 'string' },
                                            name                 => { type => 'string' },
                                            distributions        => { type => 'integer' },
                                            recent_distributions => { type => 'integer' },
                                            last_release          => { type => 'string', format => 'date',  nullable => json_true },
                                            last_new_release      => { type => 'string', format => 'date',  nullable => json_true },
                                            average_kwalitee      => { type => 'number', format => 'float', nullable => json_true },
                                            average_core_kwalitee => { type => 'number', format => 'float', nullable => json_true },
                                            registered            => { type => 'string', format => 'date',  nullable => json_true },
                                        },
                                    },
                                },
                                module => {
                                    type       => 'object',
                                    properties => {
                                        module   => { type => 'string' },
                                        version  => { type => 'string' },
                                        released => { type => 'string', format => 'date' },
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
    };
}

sub _load ($self, $params = {}) {
    my $acme_authors_table = $self->db->table('AcmeAuthors');
    my $acme_modules_table = $self->db->table('AcmeModules');
    my $authors_table      = $self->db->table('Authors');
    my $whois_table        = $self->db->table('Whois');

    my $module = $acme_modules_table->find($params->{module_id})
        or return $self->bad_request("Unknown ID: $params->{module_id}");

    my %module_info = (
        name     => $module->{module},
        version  => $module->{version},
        released => ymd($module->{released}),
    );

    my $pause_ids  = $acme_authors_table->select_authors_by_module_id($params->{module_id});
    my $rows       = $authors_table->select_all_by_pause_ids($pause_ids);
    my $whois_rows = $whois_table->select_all_by_pause_ids($pause_ids);
    my %whois_map  = map { $_->{pause_id} => $_ } @$whois_rows;
    for my $row (@$rows) {
        $row->{average_kwalitee}      = kwalitee_score($row->{average_kwalitee});
        $row->{average_core_kwalitee} = kwalitee_score($row->{average_core_kwalitee});
        for my $key (qw/last_release last_new_release/) {
            my $value = delete $row->{ $key . '_at' };
            $row->{$key} = $value ? ymd($value) : undef;
        }
        $row->{distributions}        = delete $row->{cpan_dists};
        $row->{recent_distributions} = delete $row->{recent_dists};
        delete $row->{$_} for qw/json json_updated_at has_perl6 rank/;

        my $whois = $whois_map{ $row->{pause_id} };
        $row->{name}       = decode_utf8($whois->{name});
        $row->{registered} = ymd($whois->{introduced}) if $whois->{introduced};
        $row->{deleted}    = $whois->{deleted} if $whois->{deleted};
    }

    return {
        recordsTotal => scalar @$rows,
        data         => $rows,
        module       => \%module_info,
    };
}

1;
