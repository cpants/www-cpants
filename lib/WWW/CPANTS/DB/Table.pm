package WWW::CPANTS::DB::Table;

use Mojo::Base -base, -signatures;
use String::CamelCase qw/decamelize/;
use DBI               qw/:sql_types/;
use Const::Fast;

has 'handle';
has 'meta' => \&_build_meta;
has 'name' => \&_build_name;

sub columns ($self) {
    my $class = ref $self || $self;
    no strict 'refs';
    @{"$class\::COLUMNS"};
}

sub indices ($self) {
    my $class = ref $self || $self;
    no strict 'refs';
    @{"$class\::INDICES"};
}

sub _build_name ($self) {
    my ($name) = (ref $self || $self) =~ /::(\w+)$/;
    $name =~ /[a-z]/ ? decamelize($name) : lc $name;
}

sub _build_meta ($self) {
    my %meta = (
        name    => $self->name,
        columns => [],
        primary => undef,
        unique  => undef,
    );
    my $handle = $self->handle;
    for my $column ($self->columns) {
        my ($name, $type, %opts) = @$column;
        if (exists $handle->virtual_types->{$type}) {
            my ($real_type, %extra) = @{ $handle->virtual_types->{$type} };
            $type = $real_type;
            %opts = (%opts, %extra) if %extra;
        }
        my $sql_type =
              $type =~ /int/i           ? SQL_INTEGER
            : $type =~ /float|decimal/i ? SQL_FLOAT
            :                             SQL_VARCHAR;
        push @{ $meta{columns} }, {
            %opts,
            name     => $name,
            type     => $type,
            sql_type => $sql_type,
        };
        if ($opts{primary}) {
            $meta{primary} = $name;
        }
        if ($opts{unique}) {
            $meta{unique} = $name;
        }
    }
    const my $const_meta => \%meta;
    $const_meta;
}

sub setup ($self) {
    $self->handle->create_table($self);
    $self;
}

sub is_setup ($self) {
    $self->handle->is_accessible_to($self);
}

sub migrate ($self) {
    $self->handle->migrate($self);
    $self;
}

sub schema ($self) {
    join "\n", $self->handle->ddl_statements($self)->@*;
}

sub bulk_insert ($self, $rows = undef, $opts = {}) {
    $self->handle->bulk_insert($self, $rows, $opts);
}

sub exists ($self, $where = {}) {
    $self->handle->exists($self, $where);
}

sub count ($self, $where = {}) {
    $self->handle->count($self, $where);
}

sub do ($self, $sql, @bind_values) {
    $self->handle->do($sql, @bind_values);
}

sub insert ($self, $sql, @bind_values) {
    $self->handle->insert($sql, @bind_values);
}

sub update ($self, $sql, @bind_values) {
    $self->handle->update($sql, @bind_values);
}

sub delete ($self, $sql, @bind_values) {
    $self->handle->delete($sql, @bind_values);
}

sub select ($self, $sql, @bind_values) {
    $self->handle->select($sql, @bind_values);
}

sub select_all ($self, $sql, @bind_values) {
    $self->handle->select_all($sql, @bind_values);
}

sub select_col ($self, $sql, @bind_values) {
    $self->handle->select_col($sql, @bind_values);
}

sub select_all_col ($self, $sql, @bind_values) {
    $self->handle->select_all_col($sql, @bind_values);
}

sub update_and_get_updated_rowid ($self, $updater, $selector, @bind_values) {
    $self->handle->update_and_get_updated_rowid($updater, $selector, @bind_values);
}

sub txn ($self) { $self->handle->txn }

sub truncate ($self) {
    $self->handle->truncate($self);
}

sub select_max_id ($self) {
    $self->handle->select_max_id($self);
}

sub attach ($self, $table) {
    $self->handle->attach($table);
}

sub prepare ($self, $sql, $opts = undef) {
    $self->handle->prepare($sql, $opts);
}

sub iterate ($self, $sql = undef, @bind_values) {
    if (!defined $sql) {
        my $table = $self->name;
        $sql = "SELECT * FROM $table";
    }
    $self->handle->iterate($sql, @bind_values);
}

sub find ($self, $value) {
    my $primary    = $self->meta->{primary} or Carp::croak "requires primary key";
    my $table_name = $self->name;
    my $sql        = <<~";";
        SELECT * FROM $table_name
        WHERE $primary = ?
        LIMIT 1
        ;
    $self->select($sql, $value);
}

sub find_all ($self, $values) {
    my $primary    = $self->meta->{primary} or Carp::croak "requires primary key";
    my $table_name = $self->name;
    my $sql        = <<~";";
        SELECT * FROM $table_name
        WHERE $primary IN (:values)
        ;
    $self->select_all($sql, [values => $values]);
}

sub dump_me ($self) {
    my $table_name = $self->name;
    my $sql        = <<~";";
        SELECT * FROM $table_name
        ;
    $self->select_all($sql);
}

1;
