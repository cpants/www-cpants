package WWW::CPANTS::API::Model::V5::Dist::Prereq;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::API::Model', -signatures;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Util::CoreList;
use WWW::CPANTS::Util::Distname;
use WWW::CPANTS::Util::JSON;

with qw/WWW::CPANTS::Role::API::Model::V5::Dist::GetUid/;

sub path_template ($self) { '/dist/{name}/prereq' }

sub operation ($self) {
    +{
        tags        => ['Distribution'],
        description => 'Returns prerequisites of the distribution',
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
                description => 'prerequisites of the distribution',
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
    my $requires = $db->table('RequiresAndUses')->select_requires_by_uid($uid);

    my $requires_map = decode_json($requires // '{}');
    my @modules;
    for my $phase_type (keys %$requires_map) {
        push @modules, keys %{ $requires_map->{$phase_type} // {} };
    }

    my $latest_dists = $db->table('PackagesDetails')->select_all_by_modules(\@modules);

    my %dist_map = map { $_->{module} => $_ } @$latest_dists;

    my %prereqs;
    for my $phase_type (keys %$requires_map) {
        for my $module (sort keys %{ $requires_map->{$phase_type} // {} }) {
            my $latest_dist = $dist_map{$module};
            my $info        = $latest_dist ? distinfo($latest_dist->{path}) : {};
            my $item        = {
                name              => $module,
                version           => $requires_map->{$phase_type}{$module},
                latest_dist       => $info->{distvname} // '',
                latest_version    => $info->{version}   // '',
                latest_maintainer => $info->{author}    // '',
            };
            if (my $core_since = core_since($module, $requires_map->{$phase_type}{$module})) {
                $item->{core_since} = $core_since;
                if (my $deprecated = deprecated_core_since($module)) {
                    $item->{deprecated_core_since} = $deprecated;
                }
                if (my $removed = removed_core_since($module)) {
                    $item->{removed_core_since} = $removed;
                }
            }
            push @{ $prereqs{$phase_type} //= [] }, $item;
        }
    }

    return {
        data => \%prereqs,
    };
}

1;
