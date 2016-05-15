package WWW::CPANTS::DB::Handle;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use WWW::CPANTS::Util::SQL;
use DBI;
use DBIx::TransactionManager;

sub new ($class, $base, $config = {}, $table = undef) {
  my $self = bless {pid => $$, config => $config, base => $base}, $class;
  $self->connect($table) or return;
  $self->init;
  $self;
}

sub init ($self) {}

sub dbh ($self) { $self->{dbh} //= $self->connect }

sub schema ($self, $table) {
  join "\n", @{$self->_schema($table)};
}

sub setup ($self, $table) {
  $self->do($_) for @{$self->_schema($table)};

  $self->after_setup;
  return 1;
}

sub after_setup ($self) {}

sub _schema {}

sub connect ($self, $table = undef) {
  return $self->{dbh} if $self->{dbh} && $self->{dbh}->ping;
  if (!$self->{connect_args}) {
    my $dsn = $self->dsn($table) or return;

    my $conf = ($self->{config} // {})->{$self->driver_name} // {};
    my %attr = (
      AutoCommit => 1,
      RaiseError => 1,
      PrintError => 0,
      ShowErrorStatement => 1,
      %{$self->default_attr // {}},
      %{$conf->{attr} // {}},
    );
    $self->{connect_args} = [$dsn, @$conf{qw/user pass/}, \%attr];
  }

  $self->_disconnect if $self->{dbh};
  $self->{dbh} = DBI->connect(@{$self->{connect_args}}) or croak DBI->errstr;
}

sub disconnect ($self) {
  return unless $self->{pid} eq $$ && $self->{dbh};
  $self->_disconnect;
}

sub _disconnect ($self) {
  $_ && $_->finish for values %{$self->{sth} // {}};
  delete $self->{sth};
  delete $self->{txn_manager};
  $self->__disconnect;
  $self->{dbh}->disconnect;
  delete $self->{dbh};
}

sub __disconnect ($self) {}

sub do ($self, $sql, @bind) {
  try_and_log_error {
    if (blessed $sql and $sql->isa('DBI::st')) {
      $sql->execute(@bind);
    } else {
      $self->dbh->do($self->append_caller_info($sql), undef, @bind);
    }
  };
}

sub insert ($self, $sql, @bind) {
  $self->do($sql, @bind);
}

sub update ($self, $sql, @bind) {
  $self->do($sql, @bind);
}

sub delete ($self, $sql, @bind) {
  $self->do($sql, @bind);
}

sub iterate ($self, $sql, @bind) {
  my $sth = $self->dbh->prepare($self->append_caller_info($sql));
  $sth->execute(@bind);
  WWW::CPANTS::DB::Handle::Iterator->new($sth);
}

sub select ($self, $sql, @bind) {
  my $row = $self->dbh->selectrow_hashref($self->append_caller_info($sql), undef, @bind);
  return $row;
}

sub select_all ($self, $sql, @bind) {
  my $rows = $self->dbh->selectall_arrayref($self->append_caller_info($sql), {Slice => +{}}, @bind);
  return $rows;
}

sub select_col ($self, $sql, @bind) {
  my ($col) = $self->dbh->selectrow_array($self->append_caller_info($sql), undef, @bind);
  return $col;
}

sub select_all_col ($self, $sql, @bind) {
  my $cols = $self->dbh->selectcol_arrayref($self->append_caller_info($sql), undef, @bind);
  return $cols;
}

sub exists ($self, $table, $cond) {
  my $table_name = $table->name;
  my @columns = sort keys %{$cond // {}};
  my $where = @columns ? join ' AND ', map {"$_ = ?"} @columns : "";
  my @bind = map {$where->{$_}} @columns;
  my $sql = "SELECT 1 FROM $table_name $where LIMIT 1";
  $self->select_col($sql, @bind);
}

sub count ($self, $table, $cond) {
  my $table_name = $table->name;
  my @columns = sort keys %{$cond // {}};
  my $where = @columns ? join ' AND ', map {"$_ = ?"} @columns : "";
  my @bind = map {$where->{$_}} @columns;
  my $sql = "SELECT COUNT(*) FROM $table_name $where";
  $self->select_col($sql, @bind);
}

sub append_caller_info ($self, $sql) {
  return $sql if ref $sql;
  my $i = 1;
  while(my @caller = caller($i++)) {
    my $package = $caller[0];
    next unless $package =~ /^WWW::CPANTS::(?:Bin::Task|Web::Page|Web::API)/;
    # log(debug => "[QUERY] $sql\t[$package $caller[2]]");
    return "$sql /* in $package line $caller[2] */";
  }
  return $sql;
}

sub prepare ($self, $sql) {
  $self->dbh->prepare($self->append_caller_info($sql));
}

sub select_max_id ($self, $table) {
  # TODO: check primary key column
  $self->select_col([$table, [\'MAX(id)']]);
}

sub txn ($self) {
  ($self->{txn_manager} //= do {
    my $dbh = $self->dbh;
    DBIx::TransactionManager->new($dbh)
  })->txn_scope;
}

sub attach ($self, $table) {}

sub quote_and_concat ($self, $params) {
  my $dbh = $self->dbh;
  join ', ', map {$dbh->quote($_)} @$params;
}

sub limit_offset ($self, $limit = undef, $offset = undef) {
  return '' unless defined $limit;
  if (!defined is_int($limit)) {
    log(warn => $self->append_caller_info("limit $limit is not number"));
    return '';
  }
  return "LIMIT $limit" unless defined $offset;
  if (!defined is_int($offset)) {
    log(warn => $self->append_caller_info("offset $offset is not number"));
    return '';
  }
  return "LIMIT $limit OFFSET $offset";
}

sub DESTROY ($self) { $self->disconnect }

package WWW::CPANTS::DB::Handle::Iterator;

use WWW::CPANTS;

sub new ($class, $sth) { bless {sth => $sth}, $class }
sub next ($self) { $self->{sth}->fetchrow_hashref }

1;
