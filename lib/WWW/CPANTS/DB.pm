package WWW::CPANTS::DB;

use WWW::CPANTS;
use WWW::CPANTS::Util;

sub new ($class, $config = {}) {
    my $type = $config->{type} // 'SQLite';
    my $base = $config->{base};
    my $self = bless {
        base   => $base,
        type   => $type,
        config => $config // {},
        tables => {},
    }, $class;
    $self->{handle} = $self->connect;
    $self;
}

sub connect ($self, $table = undef) {
    return $self->{handle} if $self->{handle};

    my $handle_class = $self->{handle_class} //= use_module((ref $self) . '::Handle::' . $self->{type});
    my $handle       = $handle_class->new($self->{base}, $self->{config}, $table);
}

sub table ($self, $name) {
    return $self->{tables}{$name} if $self->{tables}{$name};
    my $class       = ref $self;
    my $table_class = use_module($class . '::Table::' . $name);
    my $table       = $table_class->new($self->connect($table_class->name));
    $self->{tables}{$name} = $table;
}

sub table_names ($self) {
    my @names;
    my $class = ref $self;
    my $base  = $class . '::Table';
    for my $module (sort { $a cmp $b } findallmod $base) {
        (my $name = $module) =~ s/^${base}:://;
        push @names, $name;
    }
    @names;
}

sub advisory_lock ($self, @names) {
    my $dir = tmp_dir('lock');
    $dir->mkpath unless -d $dir;
    for my $name (@names) {
        my $lockfile = $dir->child($name . ".lock");
        return if -f $lockfile;
        my $lock_tmpfile = $dir->child($name . ".lock.$$");
        $lock_tmpfile->spew($$);
        rename $lock_tmpfile => $lockfile or do {
            unlink $lock_tmpfile;
            return;
        };
        $self->{lock}{$name} = $lockfile;
    }
    return 1;
}

sub advisory_unlock ($self, @names) {
    my $dir = tmp_dir('lock');
    return unless -d $dir;
    for my $name (@names) {
        my $lockfile = $dir->child($name . ".lock");
        next unless -f $lockfile;
        my $pid = $lockfile->slurp;
        next unless $pid eq $$;
        unlink $lockfile;
        delete $self->{lock}{$name};
    }
}

sub DESTROY ($self) {
    if (%{ $self->{lock} // {} }) {
        for my $lockfile (values %{ $self->{lock} }) {
            next unless -f $lockfile;
            my $pid = $lockfile->slurp;
            next unless $pid eq $$;
            unlink $lockfile;
        }
    }
}

1;
