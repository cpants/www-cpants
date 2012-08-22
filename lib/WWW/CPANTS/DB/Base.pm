package WWW::CPANTS::DB::Base;

use strict;
use warnings;
use DBI;
use WWW::CPANTS::AppRoot;

sub url    {}
sub dbname {}
sub schema {}

sub new { my $class = shift; bless {@_}, $class }

sub setup {
  my $self = shift;
  my $dbh = $self->dbh;
  $dbh->begin_work;
  $dbh->do($_) for split /\n\n/, $self->schema;
  $dbh->commit;
}

sub dbfile {
  my $self = shift;
  unless ($self->{dbfile}) {
    my $dir = dir('db')->mkdir;
    $self->{dbfile} = file($dir, $self->dbname);
  }
  $self->{dbfile};
}

sub dbh {
  my $self = shift;
  unless ($self->{dbh} && $self->{dbh}->{Active}) {
    $self->{dbh} = DBI->connect("dbi:SQLite:".$self->dbfile,'','', {
      AutoCommit => 1,
      RaiseError => 1,
      PrintError => 0,
      ShowErrorStatement => 1,
      sqlite_use_immediate_transaction => 1,
    });
    $self->{dbh}->do('pragma synchronous = off');
#    $self->{dbh}->do('pragma journal_mode = wal');
    $self->{dbh}->sqlite_busy_timeout(30000); # 30 secs
    if ($self->{profile}) {
      $self->set_profiler($self->{profile});
    }
    if ($self->{trace}) {
      $self->set_tracer($self->{trace});
    }
  }
  $self->{dbh};
}

sub remove {
  my $self = shift;
  if ($self->{dbh}) {
    $self->{dbh}->disconnect;
    delete $self->{dbh};
  }
  $self->{dbfile}->remove;
}

sub set_profiler {
  my ($self, $value) = @_;
  my $cb = ref $value ? $value :
           !$value    ? undef :
           sub {print STDERR "# $_[0]: $_[1]\n"};
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
  return unless $self->{explain};
  my $plan = $self->dbh->selectall_arrayref("EXPLAIN QUERY PLAN ".shift, undef, @_);
  # print STDERR "i|o|f|detail\n" if @$plan;
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

sub fetchall_in_a_page {
  my $self = shift;
  my $opts = (ref $_[-1] eq ref {}) ? pop @_ : {limit => 100, page => 1};
  my $limit    = _num($opts->{limit}, 100);
  my $page     = _num($opts->{page}, 1);
  my $offset   = ($page - 1) * $limit;
  my $limit_ex = $limit + 1;

  my ($sql, @params) = @_;
  $sql .= " limit $limit_ex offset $offset";

  $self->explain($sql, @params);
  my $rows = $self->dbh->selectall_arrayref($sql, {Slice => {}}, @params);

  my $prev = $page > 1 ? $page - 1 : undef;
  my $next;
  if (@$rows == $limit_ex) {
    pop @$rows;
    $next = $page + 1;
  }

  return { rows => $rows, prev => $prev, next => $next };
}

sub _num {
  my ($num, $default) = @_;
  $num = '' unless defined $num && $num =~ /^[0-9]+$/;
  $num ||= $default;
  $num;
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
  my $self = shift;
  $self->explain(@_);
  $self->dbh->do(shift, undef, @_);
}

sub in_params {
  my $self = shift;
  my $dbh = $self->dbh;

  # Much better to use bind params if there's no limitation for the
  # num of bind params in sqlite... (SQLITE_MAX_VARIABLE_NUMBER)
  join ',', map { $dbh->quote($_) } (ref $_[0] eq ref [] ? @{$_[0]} : @_);
}

sub bulk {
  my ($self, $sql, $rows) = @_;

  my $dbh = $self->dbh;
  my ($sth, $sth0);
  if (!ref $sql) {
    $sth = $dbh->prepare($sql);
  }
  elsif (ref $sql and ref []) {
    $sth  = $dbh->prepare($sql->[0]);
    $sth0 = $dbh->prepare($sql->[1]) if $sql->[1];
  }
  else {
    die "requires sql(s)";
  }

  my $ct = 0;
  $dbh->{AutoCommit} = 0;
  for (@$rows) {
    my $ret = $sth->execute(@$_);
    if ($sth0 and $ret and $ret eq '0E0') {
      $ret = $sth0->execute(@$_);
    }
    $dbh->commit unless ++$ct % 1000;
  }
  $dbh->{AutoCommit} = 1;
}

sub txn {
  my ($self, $callback, @args) = @_;

  my $dbh = $self->dbh;
  $dbh->begin_work;
  eval { $callback->($self, @args) };
  warn $@ if $@;
  $@ ? $dbh->rollback : $dbh->commit;
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::Base

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
