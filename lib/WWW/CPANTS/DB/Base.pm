package WWW::CPANTS::DB::Base;

use strict;
use warnings;
use Carp;
use WWW::CPANTS::AppRoot;
use WWW::CPANTS::Log;
use DBI qw/:sql_types/;
use String::CamelCase qw/decamelize/;

our %TABLES;

sub _columns { # for test
  [ id => 'integer primary key', {bulk_key => 1} ],
  [ text => 'text' ],
  [ extra => 'text', {no_bulk => 1} ],
}

sub _indices { return }

sub table {
  my $class = ref $_[0] || $_[0];
  unless ($TABLES{$class}) {
    my ($basename) = $class =~ /::(\w+)$/;
    $TABLES{$class} = decamelize($basename);
  }
  $TABLES{$class};
}

sub dbname { shift->table . ".db" }

sub dbfile {
  my $self = shift;
  unless ($self->{dbfile}) {
    my $dir = dir('db')->mkdir;
    $self->{dbfile} = file($dir, $self->dbname);
  }
  $self->{dbfile};
}

sub new { my $class = shift; bless {@_}, $class }

sub dbh {
  my $self = shift;
  unless ($self->{dbh} && $self->{dbh}->{Active}) {
    $self->{dbh} = DBI->connect("dbi:SQLite:".$self->dbfile,'','', {
      AutoCommit => 1,
      RaiseError => 1,
      PrintError => 0,
      ShowErrorStatement => 1,
      sqlite_use_immediate_transaction => $self->{readonly} ? 0 : 1,
#      sqlite_see_if_its_a_number => 1,
    });
    $self->{dbh}->sqlite_busy_timeout(60000); # 60 secs
    if (my $profile = $self->{profile} || $ENV{WWW_CPANTS_PROFILE}) {
      $self->set_profiler($profile);
    }
    if (my $trace = $self->{trace} || $ENV{WWW_CPANTS_TRACE}) {
      $self->set_tracer($trace);
    }
    if (my $threshold = $ENV{WWW_CPANTS_SLOW_QUERY}) {
      $self->set_profiler(sub {
        my ($stmt, $elapsed) = @_;
        $elapsed /= 1000;
        $self->log(debug => "[SLOW] $stmt: $elapsed") if $elapsed > ($threshold || 5);
      });
    }
  }
  $self->{dbh};
}

sub setup {
  my $self = shift;

  return $self if $self->is_setup;

  my $dbh = $self->dbh;
  $dbh->do("pragma journal_mode = WAL");
  $dbh->begin_work;

  my $table = $self->table;
  my $defs = $self->_column_def;
  $dbh->do("create table if not exists $table ($defs)");
  $dbh->do("create table if not exists meta (key, value)");

  $self->_create_indices;

  $dbh->commit;
  $self->disconnect;

  $self;
}

sub _create_indices {
  my $self = shift;
  my $dbh = $self->dbh;
  my $table = $self->table;

  my $unique = '';
  for my $index ($self->_indices) {
    if ($index eq 'unique') {
      $unique = 'unique'; next;
    }
    my $name = 'idx_' . (join '_', @$index);
    $name =~ s/[^a-z0-9_]+/_/g;
    my $cols = join ',', @$index;
    $dbh->do("create $unique index if not exists $name on $table ($cols)");
    $unique = '';
  }
}

sub _column_def {
  my $self = shift;

  my $dbh = $self->dbh;
  my @defs;
  for my $column ($self->_columns) {
    my ($name, $def, $extra) = @$column;
    push @defs, join ' ', grep defined, $dbh->quote($name), $def;
  }
  return join ',', @defs;
}

sub is_setup {
  my $self = shift;
  return unless $self->dbfile->exists;
  my $dbh = $self->dbh;
  my ($sql) = $dbh->selectrow_array("select sql from sqlite_master where type = ? and name = ?", undef, "table", $self->table);
  return $sql ? 1 : 0;
}

sub check_schema {
  my $self = shift;
  my $table = $self->table;
  my $info = $self->fetchall("pragma table_info($table)");
  my %map = map { ($_->{name} => -1) } @$info;
  my @should_add;
  for my $column ($self->_columns) {
    my ($name, $def, $extra) = @$column;
    if ($map{$name}) {
      $map{$name} = 1;
    }
    else {
      push @should_add, $name;
    }
  }
  my @should_delete = grep { $map{$_} == -1 } keys %map;

  return if !@should_add && !@should_delete;

  warn "$table schema is old; updating $table\n";
  warn "add: ".join(',', @should_add)."\n" if @should_add;
  warn "delete: ".join(',', @should_delete)."\n" if @should_delete;

  my $dbh = $self->dbh;

  my $def = $self->_column_def;
  my $old_cols = join ',', sort map { $dbh->quote_identifier($_) } grep { $map{$_} > 0 } keys %map;
  my $new_cols = join ',', sort map { $dbh->quote_identifier($_->[0]) } $self->_columns;

  $dbh->begin_work;
  eval {
    $dbh->do("create temp table temp_$table ($old_cols)");
    $dbh->do("insert into temp_$table ($old_cols) select $old_cols from $table");
    $dbh->do("drop table $table");
    $dbh->do("create table $table ($def)");
    $dbh->do("insert into $table ($old_cols) select $old_cols from temp_$table");
    $dbh->do("drop table temp_$table");
    $self->_create_indices;
    $dbh->commit;
  };
  if ($@) {
    $dbh->rollback;
    die "schema update error: $@\n";
  }
  warn "updated $table successfully\n";
}

sub set_test_data {
  my ($self, %data) = @_;
  $self->dbfile->remove if $data{clean};
  $self->setup;
  $self->{$_} = delete $data{$_} for qw/explain profile trace/;

  my $int_pk = map  { $_->[0] }
               grep { $_->[1] =~ /integer primary key/i }
               $self->_columns;
  $int_pk ||= $data{serial};

  my @cols = @{delete $data{cols} || []};
  my $cb = $self->can('_fix_test_data');
  my $id = 1;
  for (@{delete $data{rows} || []}) {
    my %row;
    @row{@cols} = @$_;
    $row{$int_pk} ||= $id++ if $int_pk;
    $cb->(\%row, \%data) if $cb;
    $self->bulk_insert(\%row);
  }
  $self->finalize_bulk_insert;
  $self;
}

sub _prepare_bulk_insert {
  my $self = shift;

  my $dbh = $self->dbh;
  $dbh->do("pragma synchronous = off");

  my (@keys, @cols, @key_types, @col_types);
  for ($self->_columns) {
    if ($_->[2] && $_->[2]{bulk_key}) {
      push @keys, $_->[0];
      push @key_types,
        $_->[1] =~ /integer/ ? SQL_INTEGER :
        $_->[1] =~ /float/ ? SQL_FLOAT :
        SQL_VARCHAR;
    }
    elsif (!$_->[2] or !$_->[2]{no_bulk}) {
      push @cols, $_->[0];
      push @col_types,
        $_->[1] =~ /integer/ ? SQL_INTEGER :
        $_->[1] =~ /float/ ? SQL_FLOAT :
        SQL_VARCHAR;
    }
  }
  my $table = $self->table;

  my @sths;
  push @sths, $dbh->prepare(join '',
    "insert or ignore into $table (",
      (join ',', @cols, @keys),
    ") values (",
      (join ',', map {'?'} @cols, @keys),
    ")");

  if (@keys && @cols) {
    push @sths, $dbh->prepare(join '',
      "update $table set ",
        (join ',', map {"$_ = ?"} @cols),
      " where ",
        (join ' and ', map {"$_ = ?"} @keys));
  }

  $self->{_bulk_insert_sths} = \@sths;
  $self->{_bulk_insert_cols} = [@cols, @keys];
  $self->{_bulk_insert_types} = [@col_types, @key_types];
}

sub bulk_insert {
  my ($self, $row) = @_;

  my $dbh = $self->dbh;
  my $rows = $self->{_bulk_insert_rows} ||= [];

  unless ($self->{_bulk_insert_sths}) {
    $self->_prepare_bulk_insert;
  }
  $row->{status} = 0 if $self->{marked};

  if (@$rows > 100) {
    $dbh->begin_work;
    my $retry = 10;
    while ($retry--) {
      eval {
        for my $row (@$rows) {
          my $sth = $self->{_bulk_insert_sths}[0];
          my $types = $self->{_bulk_insert_types};
          for my $i (0 .. @$row-1) {
            $sth->bind_param($i + 1, $row->[$i], {TYPE => $types->[$i]});
          }
          my $ret = $sth->execute;
          if ((!$ret or $ret eq '0E0') and $self->{_bulk_insert_sths}[1]) {
            my $sth = $self->{_bulk_insert_sths}[1];
            for my $i (0 .. @$row-1) {
              $sth->bind_param($i + 1, $row->[$i], {TYPE => $types->[$i]});
            }
            $ret = $sth->execute;
          }
        }
      };
      if ($@) {
        $self->log(warn => "retry bulk insert: $@");
        $dbh->rollback;
        $dbh->begin_work;
        sleep 5;
        next;
      }
      last;
    }
    unless ($retry) {
      $dbh->rollback;
      $self->log(error => "bulk insert failed badly");
      croak "bulk insert failed badly\n";
    }
    $dbh->commit;
    @$rows = ();
  }
  push @$rows, [@$row{@{$self->{_bulk_insert_cols}}}];
}

sub finalize_bulk_insert {
  my $self = shift;

  my $dbh = $self->dbh;
  if ($self->{_bulk_insert_rows}) {
    $dbh->begin_work;
    my $retry = 10;
    while ($retry--) {
      eval {
        for my $row (@{$self->{_bulk_insert_rows}}) {
          my $sth = $self->{_bulk_insert_sths}[0];
          my $types = $self->{_bulk_insert_types};
          for my $i (0 .. @$row-1) {
            $sth->bind_param($i + 1, $row->[$i], {TYPE => $types->[$i]});
          }
          my $ret = $sth->execute;
          if ((!$ret or $ret eq '0E0') and $self->{_bulk_insert_sths}[1]) {
            my $sth = $self->{_bulk_insert_sths}[1];
            for my $i (0 .. @$row-1) {
              $sth->bind_param($i + 1, $row->[$i], {TYPE => $types->[$i]});
            }
            $ret = $sth->execute;
          }
        }
      };
      if ($@) {
        $self->log(warn => "retry finalize: $@");
        $dbh->rollback;
        $dbh->begin_work;
        sleep 5;
        next;
      }
      last;
    }
    unless ($retry) {
      $dbh->rollback;
      $self->log(error => "bulk insert failed badly");
      croak "bulk insert failed badly\n";
    }
    $dbh->commit;
  }

  delete $self->{_bulk_insert_rows};
  delete $self->{_bulk_insert_sths};
  delete $self->{_bulk_insert_types};

  $dbh->do("pragma synchronous = on");
}

sub mark {
  my $self = shift;
  my $table = $self->table;

  croak "$table does not have a 'status' column" unless grep {$_->[0] eq 'status'} $self->_columns;

  $self->do("update $table set status = 1");
  $self->{marked} = 1;
}

sub unmark {
  my $self = shift;
  my $table = $self->table;
  $self->do("delete from $table where status = 1");
  delete $self->{marked};
}

sub bulk {
  my ($self, $id, $sql, @bind) = @_;

  my $dbh = $self->dbh;
  my $sth = $self->{_sth}{$id};
  unless ($sth) {
    my $retry = 10;
    my $error;
    while ($retry--) {
      $sth = eval { $dbh->prepare($sql) };
      if ($error = $@) {
        $self->log(warn => "retry prepare: $@");
        sleep 5;
        next;
      }
      last;
    }
    $self->{_sth}{$id} = $sth or do {
      $self->log(error => ($error ||= "prepare failed: $sql"));
      croak $error;
    };
  }

  push @{ $self->{_bind}{$id} ||= [] }, \@bind;
  if (@{ $self->{_bind}{$id} } > 100) {
    $dbh->begin_work;
    eval {
      $sth->execute(@$_) for @{ $self->{_bind}{$id} };
    };
    if ($@) {
      $dbh->rollback;
      delete $self->{_sth}{$id};
      return;
    }
    $dbh->commit;
    @{ $self->{_bind}{$id} } = ();
  }
}

sub finalize_bulk {
  my ($self, $id) = @_;
  my $dbh = $self->dbh;
  my $sth = $self->{_sth}{$id};

  my $retry = 10;
  while($retry--) {
    $dbh->begin_work;
    eval {
      $sth->execute(@$_) for @{ $self->{_bind}{$id} || [] };
    };
    if ($@) {
      $self->log(warn => "retry finalize bulk: $@");
      $dbh->rollback;
      sleep 5;
      next;
    }
    $dbh->commit;
    delete $self->{_bind}{$id};
    delete $self->{_sth}{$id};
    return;
  }
  if (!$retry) {
    delete $self->{_bind}{$id};
    delete $self->{_sth}{$id};
    $self->log(error => "bulk failed badly: $id");
    croak "bulk failed badly: $id";
  }
}

sub iterate {
  my ($self, @cols) = @_;

  unless ($self->{_iterate}) {
    my $dbh = $self->dbh;
    my $stmt = join ' ',
      "select",
      (@cols ? join ',', @cols : '*'),
      "from",
      $self->table;

    $self->{_iterate} = $dbh->prepare($stmt);
    $self->{_iterate}->execute;
  }

  if (!@cols) {
    my $got = $self->{_iterate}->fetchrow_hashref;
    if (!defined $got or $got eq '0E0') {
      delete $self->{_iterate};
      return;
    }
    return $got;
  }
  elsif (@cols == 1) {
    my ($got) = $self->{_iterate}->fetchrow_array;
    if (!defined $got or $got eq '0E0') {
      delete $self->{_iterate};
      return;
    }
    return $got;
  }
  else {
    my $got = $self->{_iterate}->fetchrow_arrayref;
    if (!defined $got or $got eq '0E0') {
      delete $self->{_iterate};
      return;
    }
    my $row = {};
    @$row{@cols} = @$got;
    return $row;
  }
}

sub backup {
  my ($self, $time) = @_;
  $time ||= time;
  my $dir = dir("db/backup/$time")->mkdir;
  my $dbfile = $dir->file($self->dbname);
  my $dbh = $self->dbh;
  $dbh->sqlite_backup_to_file($dbfile);
}

sub disconnect {
  my $self = shift;
  if ($self->{dbh}) {
    $self->{dbh}->disconnect;
    delete $self->{dbh};
    for (keys %$self) {
      delete $self->{$_} if $_ =~ /^_/;
    }
  }
}

sub remove {
  my $self = shift;
  $self->disconnect;
  $self->{dbfile}->remove;
}

sub set_profiler {
  my ($self, $value) = @_;
  my $cb = ref $value ? $value :
           !$value    ? undef :
           sub {print "# $_[0]: $_[1]\n"};
  $self->{dbh}->sqlite_profile($cb);
}

sub set_tracer {
  my ($self, $value) = @_;
  my $cb = ref $value ? $value :
           !$value    ? undef :
           sub {print STDERR "# $_[0]\n"};
  $self->{dbh}->sqlite_trace($cb);
}

sub explain {
  my $self = shift;
  my $sql = shift;
  return unless $self->{explain};
  my $plan = $self->dbh->selectall_arrayref("EXPLAIN QUERY PLAN $sql", undef, @_);
  print STDERR "EXPLAIN QUERY PLAN $sql\n";
  print STDERR (join '|', @{$_}) . "\n" for @$plan;
}

sub fetch {
  my $self = shift;
  $self->explain(@_);
  $self->dbh->selectrow_hashref(shift, undef, @_);
}

sub fetchall {
  my $self = shift;
  $self->explain(@_);
  my $rows = $self->dbh->selectall_arrayref(shift, {Slice => {}}, @_);
  wantarray ? @$rows : $rows;
}

sub fetch_1 {
  my $self = shift;
  $self->explain(@_);
  my ($col) = $self->dbh->selectrow_array(shift, undef, @_);
  return $col;
}

sub fetchall_1 {
  my $self = shift;
  $self->explain(@_);
  my $sth = $self->dbh->prepare(shift);
  $sth->execute(@_);
  $sth->bind_col(1, \my $val);
  my @vals;
  push @vals, $val while $sth->fetch;
  return wantarray ? @vals : \@vals;
}

sub do {
  my ($self, $sql, @bind) = @_;
  $self->explain($sql, @bind);
  my $retry = 10;
  my $error;
  my $dbh = $self->dbh;
  while ($retry--) {
    $dbh->begin_work;
    my $ret = eval { $dbh->do($sql, undef, @bind) };
    if ($error = $@) {
      $dbh->rollback;
      $self->log(warn => "retry do: $@");
      sleep 5;
      next;
    }
    $dbh->commit;
    return $ret;
  }
  $self->log(error => ($error ||= "do error: $sql (@bind)"));
  croak $error;
}

sub _in_params {
  my $self = shift;
  my $dbh = $self->dbh;

  # Much better to use bind params if there's no limitation for the
  # num of bind params in sqlite... (SQLITE_MAX_VARIABLE_NUMBER)
  join ',', map { $dbh->quote($_) } (ref $_[0] eq ref [] ? @{$_[0]} : @_);
}

sub attach {
  my ($self, $name, $as) = @_;
  if ($name =~ /^[A-Z][A-Za-z:]+$/) {
    my $package = "WWW::CPANTS::DB::$name";
    eval "require $package; 1" or die $@;
    my $db = $package->new;
    $name = $db->dbfile;
    $as ||= $db->table;
  }
  $name = $self->dbh->quote_identifier($name);

  # use directly dbh->do so as to skip a transaction handling
  $self->dbh->do("attach database $name as $as");
}

sub detach {
  my ($self, $name) = @_;
  if ($name =~ /^[A-Z][A-Za-z:]+$/) {
    my $package = "WWW::CPANTS::DB::$name";
    eval "require $package; 1" or die $@;
    my $db = $package->new;
    $name = $db->table;
  }
  $name = $self->dbh->quote_identifier($name);

  $self->dbh->do("detach database $name");
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::Base

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 table
=head2 dbname
=head2 dbfile
=head2 dbh
=head2 setup
=head2 is_setup
=head2 check_schema
=head2 set_test_data
=head2 bulk_insert
=head2 finalize_bulk_insert
=head2 bulk
=head2 finalize_bulk
=head2 iterate
=head2 backup
=head2 remove 
=head2 set_profiler
=head2 set_tracer
=head2 explain
=head2 fetch
=head2 fetch_1
=head2 fetchall
=head2 fetchall_1
=head2 do
=head2 disconnect
=head2 mark
=head2 unmark
=head2 attach
=head2 detach

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
