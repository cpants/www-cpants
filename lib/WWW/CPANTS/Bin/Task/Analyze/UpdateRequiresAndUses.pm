package WWW::CPANTS::Bin::Task::Analyze::UpdateRequiresAndUses;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use parent 'WWW::CPANTS::Bin::Task';

sub run ($self, @args) {
    # FIXME
}

sub setup ($self, $db = undef) {
    $self->{db}    = $db //= $self->db;
    $self->{table} = $db->table('RequiresAndUses');
    $self;
}

sub update ($self, $uid, $stash) {
    return unless exists $stash->{prereq};

    my $pause_id = $stash->{author};
    my $prereq   = $stash->{prereq} // [];
    my $uses     = $stash->{uses} // {};
    my $versions = $stash->{versions} // {};
    my %requires;
    for my $p (@$prereq) {
        $requires{ $p->{type} }{ $p->{requires} } = $p->{version};
    }

    my %use_map;
    for my $type (keys %$uses) {
        next if $type =~ /eval|require|no/;
        if ($type =~ /code/) {
            $use_map{runtime}{$_} = 1 for keys %{ $uses->{$type} };
        } elsif ($type =~ /test/) {
            $use_map{test}{$_} = 1 for keys %{ $uses->{$type} };
        } elsif ($type =~ /config/) {
            $use_map{configure}{$_} = 1 for keys %{ $uses->{$type} };
        }
    }
    my %use_list_map;
    for my $phase (keys %use_map) {
        $use_list_map{$phase} = [sort keys %{ $use_map{$phase} }];
    }

    my %provides;
    for my $file (keys %$versions) {
        my $module_versions = $versions->{$file};
        for my $module (keys %$module_versions) {
            $provides{$module} = 1;
        }
    }

    $self->runtime_requires_matches_use($uid, $stash, \%requires, \%use_list_map, \%provides);
    $self->test_requires_matches_use($uid, $stash, \%requires, \%use_list_map, \%provides);

    $self->{table}->update_requires_and_uses(
        $uid,
        $pause_id,
        encode_json(\%requires),
        encode_json(\%use_list_map),
    );
}

sub runtime_requires_matches_use ($self, $uid, $stash, $requires, $uses, $provides) {
    if ($stash->{dynamic_config}) {
        $stash->{kwalitee}{prereq_matches_use} = 1;
        return;
    }

    my $cpan = $self->cpan;

    my $required_perl = $requires->{runtime_requires}{perl};
    my ($used_perl) = grep /^v?5\./, @{ $uses->{runtime} // [] };
    $required_perl = eval { no warnings; version->parse($used_perl)->numify } if $used_perl;

    my %wanted;
    for my $module (@{ $uses->{runtime} // [] }) {
        next if $module =~ /^v?5\./;
        next if is_core($module, $required_perl);
        next if $provides->{$module};
        my $path = $cpan->indexed_path_for($module) or next;
        push @{ $wanted{$path} //= [] }, $module;
    }

    for my $phase (qw/runtime/) {
        for my $type (qw/requires recommends suggests/) {
            for my $module (keys %{ $requires->{ $phase . "_" . $type } // {} }) {
                my $path = $cpan->indexed_path_for($module) or next;
                delete $wanted{$path};
            }
        }
    }

    if (%wanted) {
        $stash->{error}{prereq_matches_use}    = [sort map { @{ $wanted{$_} } } keys %wanted];
        $stash->{kwalitee}{prereq_matches_use} = 0;
    } else {
        $stash->{kwalitee}{prereq_matches_use} = 1;
    }
}

sub test_requires_matches_use ($self, $uid, $stash, $requires, $uses, $provides) {
    if ($stash->{dynamic_config}) {
        $stash->{kwalitee}{prereq_matches_use} = 1;
        return;
    }

    my %included = map { $_ => 1 } @{ $stash->{included_modules} // [] };

    my $required_perl = $requires->{runtime_requires}{perl};
    my ($used_perl) = grep /^v?5\./, @{ $uses->{runtime} // [] }, @{ $uses->{test} // [] };
    $required_perl = eval { no warnings; version->parse($used_perl)->numify } if $used_perl;

    my $cpan = $self->cpan;
    my %wanted;
    for my $module (@{ $uses->{test} // [] }) {
        next if $module =~ /^v?5\./;
        next if is_core($module, $required_perl);
        next if $provides->{$module};
        next if $included{$module};
        my $path = $cpan->indexed_path_for($module) or next;
        push @{ $wanted{$path} //= [] }, $module;
    }

    for my $phase (qw/runtime build test/) {
        for my $type (qw/requires recommends suggests/) {
            for my $module (keys %{ $requires->{ $phase . "_" . $type } // {} }) {
                my $path = $cpan->indexed_path_for($module) or next;
                delete $wanted{$path};
            }
        }
    }

    if (%wanted) {
        $stash->{error}{build_prereq_matches_use}    = [sort map { @{ $wanted{$_} } } keys %wanted];
        $stash->{kwalitee}{build_prereq_matches_use} = 0;
    } else {
        $stash->{kwalitee}{build_prereq_matches_use} = 1;
    }
}

1;
