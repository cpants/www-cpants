package WWW::CPANTS::DB::Table;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use WWW::CPANTS::Util::SQL;

sub new ($class, $handle) {
  bless {handle => $handle}, $class;
}

sub virtual_types {+{
  _sereal_ => ['integer', primary => 1, incremental => 1],
  _upload_id_ => ['varchar(32)'],
  _pause_id_ => ['varchar(9)'],
  _cpan_path_ => ['varchar(400)', case_sensitive => 1],
  _dist_name_ => ['varchar(255)', case_sensitive => 1],
  _module_name_ => ['varchar(255)', case_sensitive => 1],
  _version_string_ => ['varchar(20)'],
  _epoch_ => ['integer'],
  _date_ => ['date'],
  _json_ => ['mediumtext'],
}}

sub meta ($self) { $self->{meta} //= do {
    my %meta = (
      name => $self->_name,
      columns => [],
      primary => undef,
    );
    for my $column ($self->columns) {
      my ($name, $type, %opts) = @$column;
      if (exists $self->virtual_types->{$type}) {
        my ($real_type, %extra) = @{$self->virtual_types->{$type}};
        $type = $real_type;
        %opts = (%opts, %extra) if %extra;
      }
      my $sql_type =
        $type =~ /int/i           ? SQL_INTEGER :
        $type =~ /float|decimal/i ? SQL_FLOAT :
        SQL_VARCHAR;
      push @{$meta{columns}}, {
        %opts,
        name => $name,
        type => $type,
        sql_type => $sql_type,
      };
      if ($opts{primary}) {
        $meta{primary} = $name;
      }
    }
    const my $const_meta => \%meta;
    $const_meta;
  };
}

sub columns ($self) {}
sub indices ($self) {}

sub handle ($self) { $self->{handle} }

sub setup ($self) {
  $self->handle->setup($self);
  $self;
}

sub migrate ($self) {
  $self->handle->migrate($self);
  $self;
}

sub quote_and_concat ($self, $params) {
  $self->handle->quote_and_concat($params);
}

sub limit_offset ($self, $limit = undef, $offset = undef) {
  $self->handle->limit_offset($limit, $offset);
}

sub _name ($self) {
  my ($name) = (ref $self || $self) =~ /::(\w+)$/;
  $name =~ /[a-z]/ ? decamelize($name) : lc $name;
}

sub name ($self) { ref $self ? $self->meta->{name} : $self->_name }

sub bulk_insert ($self, $rows = undef, $opts = undef) {
  $self->handle->bulk_insert($self, $rows, $opts);
}

sub exists ($self, $where = {}) {
  $self->handle->exists($self, $where);
}

sub count ($self, $where = {}) {
  $self->handle->count($self, $where);
}

sub insert ($self, $sql, @bind) {
  $self->handle->insert($sql, @bind);
}

sub update ($self, $sql, @bind) {
  $self->handle->update($sql, @bind);
}

sub delete ($self, $sql, @bind) {
  $self->handle->delete($sql, @bind);
}

sub iterate ($self, $sql, @bind) {
  $self->handle->iterate($sql, @bind);
}

sub select ($self, $sql, @bind) {
  $self->handle->select($sql, @bind);
}

sub select_all ($self, $sql, @bind) {
  $self->handle->select_all($sql, @bind);
}

sub select_col ($self, $sql, @bind) {
  $self->handle->select_col($sql, @bind);
}

sub select_all_col ($self, $sql, @bind) {
  $self->handle->select_all_col($sql, @bind);
}

sub update_and_get_updated_rowid ($self, $sql, @bind) {
  $self->handle->update_and_get_updated_rowid($sql, @bind);
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

sub prepare ($self, $sql) {
  $self->handle->prepare($sql);
}

sub DESTROY ($self) {
  delete $self->{sth};  # remove before handle is gone
  delete $self->{handle};
}

sub find ($self, $value) {
  my $sth = $self->{sth}{find} //= do {
    my $primary = $self->meta->{primary} or croak "requires primary key";
    my $table_name = $self->name;
    my $limit_offset = $self->limit_offset(1);
    $self->prepare(qq[
      SELECT * FROM $table_name
      WHERE $primary = ?
      $limit_offset
    ]);
  };
  $self->select($sth, $value);
}

sub find_all ($self, $values) {
  my $primary = $self->meta->{primary} or croak "requires primary key";
  my $quoted_values = $self->quote_and_concat($values);
  my $table_name = $self->name;
  $self->select_all(qq[
    SELECT * FROM $table_name
    WHERE $primary IN ($quoted_values)
  ]);
}

1;
