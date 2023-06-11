package WWW::CPANTS::DB::Handle::SQLite;

use Mojo::Base 'WWW::CPANTS::DB::Handle', -signatures;
use Syntax::Keyword::Try;
use WWW::CPANTS::Util::Path qw/cpants_path/;

my %VirtualTypes = (
    _serial_         => ['integer', primary => 1, incremental => 1],
    _upload_id_      => ['varchar(32)'],
    _pause_id_       => ['varchar(9)'],
    _cpan_path_      => ['varchar(400)', case_sensitive => 1],
    _dist_name_      => ['varchar(255)', case_sensitive => 1],
    _module_name_    => ['varchar(255)', case_sensitive => 1],
    _version_string_ => ['varchar(20)'],
    _acme_id_        => ['varchar(40)'],
    _epoch_          => ['integer'],
    _year_           => ['integer'],
    _int_            => ['integer'],
    _revision_       => ['integer'],
    _bool_           => ['integer'],
    _date_           => ['date'],
    _json_           => ['text'],
);

has 'dbfile';

sub virtual_types ($self) { \%VirtualTypes }

sub _build_dbfile ($self, $table) {
    my $dir = cpants_path('db');
    $dir->mkpath unless -d $dir;
    my $name = $table->name;
    return $dir->child("$name.db");
}

sub connect ($self, $table = undef) {
    Carp::confess "no table" unless $table;
    my $dbfile = $self->_build_dbfile($table);

    my $config = $self->config // {};
    my %attr   = (
        AutoCommit         => 1,
        RaiseError         => 1,
        PrintError         => 0,
        ShowErrorStatement => 1,
        %{ $config->{attr} // {} },
    );

    my $dbh = DBI->connect("dbi:SQLite:$dbfile", "", "", \%attr)
        or Carp::croak DBI->errstr;

    $dbh->do('PRAGMA synchronous = OFF');

    my $class = ref $self || $self;
    $class->new(
        dbfile => $dbfile,
        trace  => $self->trace,
        _dbh   => $dbh,
    );
}

sub is_accessible_to ($self, $table) {
    return unless $self->dbh;

    my $sql = <<~';';
    SELECT 1 FROM sqlite_master WHERE type = ? AND name = ?
    ;
    $self->select_col($sql, 'table', $table->name);
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
        if ($params{primary}) {
            $def .= " primary key";
            $def .= " autoincrement" if $params{incremental};
        }
        $def .= " not null"                 if $params{not_null};
        $def .= " unique"                   if $params{unique};
        $def .= " default $params{default}" if defined $params{default};
        push @column_definitions, $def;
    }
    push @sqls, "CREATE TABLE IF NOT EXISTS $table_name (" . join(", ", @column_definitions) . ")";

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
    my $table_name = $table->name;
    my $table_info = $self->select_all(qq[PRAGMA table_info($table_name)]);
    my %map        = map { $_->{name} => -1 } @$table_info;
    my @should_add;
    for my $column ($table->columns) {
        my ($name, $type, %params) = @$column;
        if ($map{$name}) {
            $map{$name} = 1;
        } else {
            push @should_add, $name;
        }
    }
    my @should_delete = grep { $map{$_} == -1 } keys %map;
    return if !@should_add && !@should_delete;

    $self->log(warn => "$table_name schema is outdated; updating");
    $self->log(warn => "add: " . join(',', @should_add))       if @should_add;
    $self->log(warn => "delete: " . join(',', @should_delete)) if @should_delete;

    my $dbh = $self->dbh;

    my $old_cols = join ',', sort map { $dbh->quote_identifier($_) } grep { $map{$_} > 0 } keys %map;
    my $new_cols = join ',', sort map { $dbh->quote_identifier($_->[0]) } $table->columns;

    $dbh->begin_work;
    try {
        my $temp = "temp_" . $table_name;
        my @sqls = (
            qq[CREATE TEMP TABLE $temp ($old_cols)],
            qq[INSERT INTO $temp ($old_cols)
           SELECT $old_cols FROM $table_name],
            qq[DROP TABLE $table_name],
            @{ $self->ddl_statements($table) },
            qq[INSERT INTO $table_name ($old_cols)
           SELECT $old_cols FROM $temp],
            qq[DROP TABLE $temp],
        );
        $dbh->do($_) for @sqls;
        $dbh->commit;
    } catch {
        my $error = $@;
        $dbh->rollback;
        die "schema migration error: $error\n";
    }
    $self->log(notice => "migrated $table_name successfully");
}

sub truncate ($self, $table) {
    my $table_name = $table->name;
    $self->delete(qq[DELETE FROM $table_name]);
}

sub update_and_get_updated_rowid ($self, $updater, $selector, @bind_values) {
    my $dbh = $self->dbh;
    my $id;
    my $sql = $updater;
    $sql =~ s/\(:id\)/($selector)/;
    my $hook = sub ($action_code, $database, $table, $rowid) { $id = $rowid };
    $dbh->sqlite_update_hook($hook);
    $self->update($sql, @bind_values);
    $dbh->sqlite_update_hook(undef);
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
    $sql .= 'OR IGNORE ' if $opts->{ignore};
    $sql .= 'INTO ' . $table->name . ' (' . join(',', @columns) . ')' . ' VALUES (' . substr('?,' x @columns, 0, -1) . ')';

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
    return join ' || ', @values;
}

1;
