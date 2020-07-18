package WWW::CPANTS::Bin::Task::Analyze::UpdateRequiresAndUses;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Util::CoreList;
use WWW::CPANTS::Util::Distname;
use WWW::CPANTS::Util::Version;

our @WRITE = qw/RequiresAndUses/;

with qw/WWW::CPANTS::Role::Task::FixAnalysis/;

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

    $self->runtime_requires_matches_use($uid, $stash, \%requires, $uses);
    $self->test_requires_matches_use($uid, $stash, \%requires, $uses);
    $self->configure_requires_matches_use($uid, $stash, \%requires, $uses);

    return if $self->dry_run;

    $self->db->table('RequiresAndUses')->update_requires_and_uses(
        $uid,
        $pause_id,
        encode_json(\%requires),
        encode_json($uses),
    );
}

sub required_perl ($self, $stash, $uses) {
    my @versions;
    for my $phase (qw/runtime test configure/) {
        next unless $uses->{$phase} && ref $uses->{$phase} eq 'HASH' && ref $uses->{$phase}{requires} eq 'HASH';
        push @versions, $uses->{$phase}{requires}{perl} if exists $uses->{$phase}{requires}{perl};
    }

    if (my $meta = $stash->{meta_yml}) {
        for my $phase (qw/requires build_requires configure_requires/) {
            next unless $meta->{$phase} && ref $meta->{$phase} eq 'HASH';
            push @versions, $meta->{$phase}{perl} if exists $meta->{$phase}{perl};
        }
    }

    my ($version) =
        sort { $b <=> $a }
        map  { numify_version($_) }
        grep { $_ } @versions;        ## ignore 0

    $stash->{required_perl} = $version;
}

sub runtime_requires_matches_use ($self, $uid, $stash, $requires, $uses) {
    my $cpan = $self->ctx->cpan;

    my $required_perl = $self->required_perl($stash, $uses);

    my (%wanted, %seen, %unindexed);
    my $declared_runtime_requires = $requires->{runtime_requires} // {};
    for my $module (keys %$declared_runtime_requires) {
        next if is_core($module, $required_perl);
        my $path = $cpan->packages->indexed_path_for($module) or next;
        $seen{$path} = 1;
    }
    my $actual_runtime_requires = $uses->{runtime}{requires} // {};
    for my $module (keys %$actual_runtime_requires) {
        next if $module eq 'perl';
        next if is_core($module, $required_perl);
        my $path = $cpan->packages->indexed_path_for($module);
        if (!$path) {
            $unindexed{$module} = 1;
            next;
        }
        if (exists $declared_runtime_requires->{$module}) {
            my $version = $actual_runtime_requires->{$module};
            if (!$version or numify_version($version) <= numify_version($declared_runtime_requires->{$module})) {
                $seen{$path} = 1;
                next;
            }
        }
        next if $seen{$path};
        push @{ $wanted{$path} //= [] }, $module;
    }
    for my $path (keys %wanted) {
        my $distinfo = valid_distinfo($path);
        if ($seen{$path} or !$distinfo or $distinfo->{name} eq $stash->{dist}) {
            delete $wanted{$path};
        }
    }

    $stash->{unindexed_runtime_requires} = [sort keys %unindexed] if %unindexed;

    if (%wanted) {
        $stash->{error}{prereq_matches_use}    = [sort map { @{ $wanted{$_} } } keys %wanted];
        $stash->{kwalitee}{prereq_matches_use} = ($stash->{dynamic_config}) ? 1 : 0;
    } else {
        $stash->{kwalitee}{prereq_matches_use} = 1;
    }
}

sub test_requires_matches_use ($self, $uid, $stash, $requires, $uses) {
    my $cpan = $self->ctx->cpan;

    my %included = map { $_ => 1 } @{ $stash->{included_modules} // [] };

    my $required_perl = $self->required_perl($stash, $uses);

    my (%wanted, %seen, %unindexed);
    my $declared_runtime_requires = $requires->{runtime_requires} // {};
    for my $module (keys %$declared_runtime_requires) {
        next if is_core($module, $required_perl);
        my $path = $cpan->packages->indexed_path_for($module) or next;
        $seen{$path} = 1;
    }
    my $declared_build_requires = $requires->{build_requires} // {};
    for my $module (keys %$declared_build_requires) {
        next if is_core($module, $required_perl);
        my $path = $cpan->packages->indexed_path_for($module) or next;
        $seen{$path} = 1;
    }
    my $actual_test_requires = $uses->{test}{requires} // {};
    for my $module (keys %$actual_test_requires) {
        next if $module eq 'perl';
        next if is_core($module, $required_perl);
        next if $included{$module};
        my $path = $cpan->packages->indexed_path_for($module);
        if (!$path) {
            $unindexed{$module} = 1;
            next;
        }
        if (exists $declared_runtime_requires->{$module}) {
            my $version = $actual_test_requires->{$module};
            if (!$version or numify_version($version) <= numify_version($declared_runtime_requires->{$module})) {
                $seen{$path} = 1;
                next;
            }
        }
        if (exists $declared_build_requires->{$module}) {
            my $version = $actual_test_requires->{$module};
            if (!$version or numify_version($version) <= numify_version($declared_build_requires->{$module})) {
                $seen{$path} = 1;
                next;
            }
        }
        next if $seen{$path};
        push @{ $wanted{$path} //= [] }, $module;
    }
    for my $path (keys %wanted) {
        my $distinfo = valid_distinfo($path);
        if ($seen{$path} or !$distinfo or $distinfo->{name} eq $stash->{dist}) {
            delete $wanted{$path};
        }
    }

    $stash->{unindexed_test_requires} = [sort keys %unindexed] if %unindexed;

    if (%wanted) {
        $stash->{error}{test_prereq_matches_use}    = [sort map { @{ $wanted{$_} } } keys %wanted];
        $stash->{kwalitee}{test_prereq_matches_use} = ($stash->{dynamic_config}) ? 1 : 0;
    } else {
        $stash->{kwalitee}{test_prereq_matches_use} = 1;
    }
}

sub configure_requires_matches_use ($self, $uid, $stash, $requires, $uses) {
    my $cpan = $self->ctx->cpan;

    my $required_perl = $self->required_perl($stash, $uses);

    my (%wanted, %seen, %unindexed);
    my $declared_configure_requires = $requires->{configure_requires} // {};
    for my $module (keys %$declared_configure_requires) {
        next if is_core($module, $required_perl);
        my $path = $cpan->packages->indexed_path_for($module) or next;
        $seen{$path} = 1;
    }
    my $actual_configure_requires = $uses->{configure}{requires} // {};
    for my $module (keys %$actual_configure_requires) {
        next if $module eq 'perl';
        next if is_core($module, $required_perl);
        my $path = $cpan->packages->indexed_path_for($module);
        if (!$path) {
            $unindexed{$module} = 1;
            next;
        }
        if (exists $declared_configure_requires->{$module}) {
            my $version = $actual_configure_requires->{$module};
            if (!$version or numify_version($version) <= numify_version($declared_configure_requires->{$module})) {
                $seen{$path} = 1;
                next;
            }
        }
        next if $seen{$path};
        push @{ $wanted{$path} //= [] }, $module;
    }
    for my $path (keys %wanted) {
        my $distinfo = valid_distinfo($path);
        if ($seen{$path} or !$distinfo or $distinfo->{name} eq $stash->{dist}) {
            delete $wanted{$path};
        }
    }

    $stash->{unindexed_configure_requires} = [sort keys %unindexed] if %unindexed;

    if (%wanted) {
        $stash->{error}{configure_prereq_matches_use}    = [sort map { @{ $wanted{$_} } } keys %wanted];
        $stash->{kwalitee}{configure_prereq_matches_use} = ($stash->{dynamic_config}) ? 1 : 0;
    } else {
        $stash->{kwalitee}{configure_prereq_matches_use} = 1;
    }
}

1;
