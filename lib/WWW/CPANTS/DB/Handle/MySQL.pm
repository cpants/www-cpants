package WWW::CPANTS::DB::Handle::MySQL;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use parent 'WWW::CPANTS::DB::Handle';

sub dsn ($self, $table) {
    my $name = "cpants";
    $name .= '_' . $self->{base} if $self->{base};
    "dbi:mysql:$name";
}

sub driver_name ($self)  { 'MySQL' }
sub default_attr ($self) { }
sub dbfile ($self)       { }

sub init ($self)        { }
sub after_setup ($self) { }
sub pragma ($self, $name, $value) { }
sub __disconnect ($self) { }

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
            $def .= " auto_increment" if $params{incremental};
        }
        $def .= " not null"                 if $params{not_null};
        $def .= " unique"                   if $params{unique};
        $def .= " default $params{default}" if defined $params{default};
        $def .= " collate utf8_bin"         if defined $params{case_sensitive};
        push @column_definitions, $def;
    }
    push @sqls, "CREATE TABLE IF NOT EXISTS $table_name (" . join(", ", @column_definitions) . ") ENGINE=InnoDB CHARACTER SET=utf8";

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
        push @sqls, "ALTER TABLE $table_name ADD $unique INDEX $name (" . join(", ", @columns) . ")";
    }
    \@sqls;
}

sub migrate ($self, $table) {
    # FIXME
    log(warn => "MySQL table migration is not implemented yet");
}

sub truncate ($self, $table) {
    my $table_name = $table->name;
    $self->delete(qq[DELETE FROM $table_name]);
}

sub update_and_get_updated_rowid ($self, $sql, @bind) {
    my $dbh = $self->dbh;
    $self->update($sql, @bind);
    $dbh->{mysql_insertid};
}

sub attach ($self, $table) { }

sub bulk_insert ($self, $table, $rows = [], $opts = {}) {
    my $bulk = WWW::CPANTS::DB::Handle::MySQL::BulkProcessor->new($table, $opts);
    return $bulk unless defined $rows;
    $bulk->insert($rows);
    $bulk->finalize;
}

package WWW::CPANTS::DB::Handle::MySQL::BulkProcessor;

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
    $sql .= "IGNORE " if $self->{opts}{ignore};
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
