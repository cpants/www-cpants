package WWW::CPANTS::DB::Handle::MySQL;

use Mojo::Base 'WWW::CPANTS::DB::Handle', -signatures;
use Syntax::Keyword::Try;

my %VirtualTypes = (
    _serial_         => ['bigint', primary => 1, incremental => 1],
    _upload_id_      => ['varchar(32)'],
    _pause_id_       => ['varchar(9)'],
    _cpan_path_      => ['varchar(400)', case_sensitive => 1],
    _dist_name_      => ['varchar(255)', case_sensitive => 1],
    _module_name_    => ['varchar(255)', case_sensitive => 1],
    _version_string_ => ['varchar(20)'],
    _acme_id_        => ['varchar(40)'],
    _epoch_          => ['bigint'],
    _year__          => ['smallint', unsigned => 1],
    _int_            => ['bigint'],
    _revision_       => ['integer'],
    _bool_           => ['tinyint'],
    _date_           => ['date'],
    _json_           => ['mediumtext'],
);

sub virtual_types ($self) { \%VirtualTypes }

sub connect ($self, $table = undef) {
    return $self if $self->dbh;

    my $config = $self->config // {};

    my $database = $config->{database} // $config->{dbname} // 'cpants';
    my $user     = $config->{user};
    my $pass     = $config->{password};
    my $dsn      = $config->{dsn} // "dbi:mysql:$database";

    my %attr = (
        AutoCommit          => 1,
        RaiseError          => 1,
        PrintError          => 0,
        ShowErrorStatement  => 1,
        AutoInactiveDestroy => 1,
        %{ $config->{attr} // {} },
    );

    my $dbh = DBI->connect($dsn, $user, $pass, \%attr)
        or Carp::croak DBI->errstr;
    $self->log(debug => "connected to $dsn [$$]");

    $self->_dbh($dbh);
    $self;
}

sub is_accessible_to ($self, $table) {
    return unless $self->dbh;

    my $sql = <<~';';
    SHOW TABLES LIKE ?
    ;
    my $rows = $self->select($sql, $table->name) or return;
    return keys %$rows == 1;
}

sub ddl_statements ($self, $table) {
    my $table_name = $table->name;

    my @sqls;
    my @column_definitions;
    for my $column ($table->columns) {
        my ($name, $type, %params) = @$column;
        if (exists $VirtualTypes{$type}) {
            my ($real_type, %extra) = @{ $VirtualTypes{$type} };
            $type   = $real_type;
            %params = (%params, %extra) if %extra;
        }
        my $def = "$name $type";
        $def .= " character set " . $params{character_set} if $params{character_set};
        $def .= " collate " . $params{collate}             if $params{collate};
        if ($params{primary}) {
            $def .= " primary key";
            $def .= " auto_increment" if $params{incremental};
        }
        $def .= " not null"                 if $params{not_null};
        $def .= " unique"                   if $params{unique};
        $def .= " default $params{default}" if defined $params{default};
        push @column_definitions, $def;
    }
    my $table_def = "CREATE TABLE IF NOT EXISTS $table_name (" . join(", ", @column_definitions) . ")";
    $table_def .= " ENGINE InnoDB CHARACTER SET utf8 COLLATE utf8_bin";
    push @sqls, $table_def;

    for my $index ($table->indices) {
        my ($unique, $where, @columns);
        if (ref $index eq 'ARRAY') {
            $unique  = $where = "";
            @columns = @$index;
        } elsif (ref $index eq 'HASH') {
            $unique  = "UNIQUE" if $index->{unique};
            $where   = $index->{where} ? " WHERE $index->{where}" : "";
            @columns = @{ $index->{columns} // [] };
        }
        die "no columns to index: $table_name" unless @columns;
        my $name = join '_', 'idx', @columns;
        $name =~ s/[^a-z0-9_]+/_/g;
        push @sqls, "CREATE $unique INDEX IF NOT EXISTS $name ON $table_name (" . join(", ", @columns) . ")$where";
    }
    \@sqls;
}

sub migrate ($self, $table) {
    Carp::carp "Not implemented yet";
    return;
}

sub truncate ($self, $table) {
    my $table_name = $table->name;
    $self->delete(qq[DELETE FROM $table_name]);
}

sub update_and_get_updated_rowid ($self, $updater, $selector, @bind_values) {
    my $dbh = $self->dbh;
    $selector .= ' FOR UPDATE';
    my $id = $self->select_col($selector);
    $self->update($updater, @bind_values, [id => [$id]]);
    $id;
}

sub bulk_insert ($self, $table, $rows, $opts = {}) {
    return unless $rows and @$rows;

    my $first_row = $rows->[0];

    my @columns;
    my @default_columns;
    my %default;
    for my $column (@{ $table->meta->{columns} }) {
        my $name = $column->{name};
        next unless exists $first_row->{$name};
        push @columns, $name;
        if (exists $column->{default}) {
            $default{$name} = $column->{default};
            push @default_columns, $name;
        }
    }
    Carp::croak "no columns to insert" unless @columns;

    $opts //= {};
    $opts->{omit_values} = 1;

    my $sql = 'INSERT ';
    $sql .= 'INTO ' . $table->name . ' (' . join(',', @columns) . ')' . ' VALUES (' . substr('?,' x @columns, 0, -1) . ')';
    if ($opts->{ignore}) {
        my $primary = $table->meta->{primary} or Carp::confess "no primary";
        $sql .= " ON DUPLICATE KEY UPDATE $primary = $primary";
    }

    my $dbh = $self->dbh;
    my $txn = $self->txn;
    my $sth = $dbh->prepare($sql);
    try {
        for my $row (@$rows) {
            my %new;
            @new{@columns} = @$row{@columns};
            if (@default_columns) {
                for my $column (@default_columns) {
                    $new{$column} //= $default{$column};
                }
            }
            $sth->execute(@new{@columns});
        }
        $txn->commit;
    } catch {
        my $error = $@;
        $self->log(error => $error);
        $txn->rollback;
    }
}

sub concat_expr ($self, @values) {
    return 'CONCAT(' . join(',', @values) . ')';
}

1;
