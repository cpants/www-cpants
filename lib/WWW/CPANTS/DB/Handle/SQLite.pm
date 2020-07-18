package WWW::CPANTS::DB::Handle::SQLite;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use parent 'WWW::CPANTS::DB::Handle';

my $SQLITE_MAX_VARIABLE_NUMBER = 999;    # FIXME

sub dsn ($self, $table) {
    return unless $table;
    my $dir = $self->{dir} //= dir($self->{base} // 'db');
    $dir->mkpath unless -d $dir;
    my $file = $self->{file} //= "$dir/$table.db";
    "dbi:SQLite:$file";
}

sub driver_name ($self)  { 'SQLite' }
sub default_attr ($self) { +{ sqlite_see_if_its_a_number => 0 } }
sub dbfile ($self)       { $self->{file} }

sub init ($self)        { $self->pragma(synchronous  => 'off') }
sub after_setup ($self) { $self->pragma(journal_mode => 'WAL') }

sub pragma ($self, $name, $value) {
    $self->do("PRAGMA $name = $value");
}

sub __disconnect ($self) {
    $self->pragma(wal_checkpoint => 'PASSIVE');
}

sub _schema ($self, $table) {
    my $table_name = $table->name;

    my @sqls;
    my @column_definitions;
    for my $column ($table->columns) {
        my ($name, $type, %params) = @$column;
        if (exists $table->virtual_types->{$type}) {
            my ($real_type, %extra) = @{ $table->virtual_types->{$type} };
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
            $unique = "UNIQUE " if $index->{unique};
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

    log(notice => "$table_name schema is outdated; updating $table_name");
    log(notice => "add: " . join(',', @should_add)) if @should_add;
    log(notice => "delete: " . join(',', @should_delete)) if @should_delete;

    my $dbh = $self->dbh;

    my $old_cols = join ',', sort map { $dbh->quote_identifier($_) } grep { $map{$_} > 0 } keys %map;
    my $new_cols = join ',', sort map { $dbh->quote_identifier($_->[0]) } $table->columns;

    $dbh->begin_work;
    eval {
        my $temp = "temp_" . $table_name;
        my @sqls = (
            qq[CREATE TEMP TABLE $temp ($old_cols)],
            qq[INSERT INTO $temp ($old_cols)
         SELECT $old_cols FROM $table_name],
            qq[DROP TABLE $table_name],
            @{ $self->_schema($table) },
            qq[INSERT INTO $table_name ($old_cols)
         SELECT $old_cols FROM $temp],
            qq[DROP TABLE $temp],
        );
        $dbh->do($_) for @sqls;
        $dbh->commit;
    };
    if ($@) {
        $dbh->rollback;
        die "schema migration error: $@\n";
    }
    log(notice => "migrated $table_name successfully");
}

sub truncate ($self, $table) {
    my $table_name = $table->name;
    $self->delete(qq[DELETE FROM $table_name]);
}

sub update_and_get_updated_rowid ($self, $sql, @bind) {
    my $dbh = $self->dbh;
    my $id;
    my $hook = sub ($action_code, $database, $table, $rowid) { $id = $rowid };
    $dbh->sqlite_update_hook($hook);
    $self->update($sql, @bind);
    $dbh->sqlite_update_hook(undef);
    $id;
}

sub attach ($self, $table) {
    WWW::CPANTS::Model::DB::Handle::SQLite::Attach->new($self->dbh, $table);
}

sub bulk_insert ($self, $table, $rows = [], $opts = {}) {
    my $bulk = WWW::CPANTS::DB::Handle::SQLite::BulkProcessor->new($table, $opts);
    return $bulk unless defined $rows;
    $bulk->insert($rows);
    $bulk->finalize;
}

package WWW::CPANTS::Model::DB::Handle::SQLite::Attach;

use WWW::CPANTS;
use WWW::CPANTS::Util;

sub new ($class, $dbh, $table) {
    my $name = $table->name;
    my $file = $dbh->quote_identifier($table->handle->dbfile);
    $dbh->do("ATTACH $file AS $name");
    bless { dbh => $dbh, name => $name }, $class;
}

sub DESTROY ($self) {
    my $name = $self->{name};
    $self->{dbh}->do("DETACH $name");
}

package WWW::CPANTS::DB::Handle::SQLite::BulkProcessor;

use WWW::CPANTS;
use WWW::CPANTS::Util;

sub new ($class, $table, $opts = {}) {
    $opts->{threshold} //= 1000;
    bless { table => $table, opts => $opts }, $class;
}

sub finalize ($self) {
    $self->_insert;
    delete $self->{_insert};
}

sub prepare_insert ($self, $row) {
    my $table = $self->{table};
    my (@columns, @names, %defaults);
    for my $column (@{ $table->meta->{columns} }) {
        next unless exists $row->{ $column->{name} };
        push @columns, $column;
        push @names,   $column->{name};
        if (exists $column->{default}) {
            $defaults{ $column->{name} } = $column->{default};
        }
    }

    return unless @columns;

    my $concat_names = join ', ', @names;
    my $placeholders = substr '?,' x @names, 0, -1;
    my $sql          = "INSERT ";
    $sql .= "OR IGNORE " if $self->{opts}{ignore};
    $sql .= "INTO " . $table->name . " ($concat_names) VALUES ($placeholders)";

    my %opts;
    $opts{columns} = \@columns;
    $opts{names}   = \@names;
    if (%defaults) {
        $opts{defaults}     = \%defaults;
        $opts{default_keys} = [keys %defaults];
    }
    $opts{sth} = $table->prepare($sql);
    $opts{row} = [];
    \%opts;
}

sub insert ($self, $rows) {
    return unless @$rows;

    my $_insert = $self->{_insert} //= $self->prepare_insert($rows->[0]) or return;
    my $_rows   = $_insert->{rows} //= [];
    my $names   = $self->{_insert}{names};
    my $defaults     = $self->{_insert}{defaults};
    my $default_keys = $self->{_insert}{default_keys};
    my $threshold    = $self->{opts}{threshold};
    for my $row (@$rows) {
        if ($default_keys) {
            $row->{$_} //= $defaults->{$_} for @$default_keys;
        }
        my @values = @$row{@$names};
        push @$_rows, \@values;
        $self->_insert if @$_rows > $threshold;
    }
}

sub _insert ($self) {
    my $_insert = $self->{_insert} or return;
    my $rows    = $_insert->{rows} // [];
    return unless @$rows;
    my $handle = $self->{table}->handle;
    my $txn    = $handle->txn;
    my $sth    = $_insert->{sth};
    $sth->execute(@$_) for @$rows;
    @$rows = ();
    $txn->commit;
}

1;
