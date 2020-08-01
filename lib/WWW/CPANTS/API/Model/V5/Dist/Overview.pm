package WWW::CPANTS::API::Model::V5::Dist::Overview;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Util::JSON;
use Pod::Escapes qw(e2char);

with qw/WWW::CPANTS::Role::API::Model::V5::Dist::GetUid/;

sub path_template ($self) { '/dist/{name}/overview' }

sub operation ($self) {
    +{
        tags        => ['Distribution'],
        description => 'Returns overview of the distribution',
        parameters  => [{
                description          => 'name of the distribution',
                in                   => 'path',
                name                 => 'name',
                required             => json_true,
                schema               => { type => 'string' },
                'x-mojo-placeholder' => '#',
            },
            {
                description => 'number of records',
                in          => 'query',
                name        => 'length',
                schema      => {
                    type    => 'integer',
                    default => 50,
                },
            },
            {
                description => 'offset',
                in          => 'query',
                name        => 'start',
                schema      => {
                    type    => 'integer',
                    default => 0,
                },
            },
        ],
        responses => {
            200 => {
                description => 'overview of the distribution',
                content     => {
                    'application/json' => {
                        schema => {
                            type       => 'object',
                            properties => {
                                data => {
                                    type => 'object',
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
    my $uid = $self->get_uid($params);
    return unless $uid;

    my $db       = $self->db;
    my $kwalitee = $db->table('Kwalitee')->find($uid);

    my $errors     = $db->table('Errors')->select_all_errors_of($uid);
    my %errors_map = map { $_->{category} => $_->{error} } @$errors;

    my (@core_issues, @extra_issues, @experimental_issues);
    for my $indicator ($self->ctx->kwalitee->indicators->@*) {
        my $k = $kwalitee->{ $indicator->{name} };
        next if !defined $k or $k;                       # pass or ignored or not checked yet
        delete $indicator->{$_} for qw/code details/;    # remove code references
        if ($indicator->{is_extra}) {
            push @extra_issues, { %$indicator, error => $errors_map{ $indicator->{name} } };
        } elsif ($indicator->{is_experimental}) {
            push @experimental_issues, { %$indicator, error => $errors_map{ $indicator->{name} } };
        } else {
            push @core_issues, { %$indicator, error => $errors_map{ $indicator->{name} } };
        }
    }

    my ($modules, $provides, $special_files);
    if (my $row = $db->table('Provides')->select_by_uid($uid)) {

        my %unauthorized = map { $_ => 1 } @{ decode_json($row->{unauthorized} // '[]') };
        $modules       = decode_json($row->{modules}       // '[]');
        $provides      = decode_json($row->{provides}      // '[]');
        $special_files = decode_json($row->{special_files} // '[]');
        for my $module (@$modules, @$provides) {
            $module->{unauthorized} = 1 if $unauthorized{ $module->{name} };
        }
    }

    for my $module (@$modules) {
        $module->{abstract} =~ s/E<([^>]+)>/e2char($1)/eg;
    }

    return {
        data => {
            modules       => $modules,
            provides      => $provides,
            special_files => $special_files,
            issues        => {
                count        => scalar(@core_issues + @extra_issues + @experimental_issues),
                core         => \@core_issues,
                extra        => \@extra_issues,
                experimental => \@experimental_issues,
            }
        },
    };
}

1;
