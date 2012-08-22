package WWW::CPANTS::DB::Analysis;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub dbname { 'analysis.db' }
sub schema { return <<'SCHEMA';
create table if not exists analysis (
  id integer primary key autoincrement,
  path text unique,
  distv text,
  author text,
  json text,
  duration integer
);
SCHEMA
}

sub has_analyzed {
  my $self = shift;
  $self->fetch_1('select id from analysis where path = ?', shift);
}

sub insert_or_update {
  my ($self, $bind) = @_;

  my $id;
  $self->dbh->sqlite_update_hook(sub {(undef, undef, undef, $id) = @_ });
  my @params = @$bind{qw/distv author json duration path/};
  my $ret = $self->do('insert or ignore into analysis (distv, author, json, duration, path) values (?, ?, ?, ?, ?)', @params);
  if ($ret and $ret eq '0E0') {
    $ret = $self->do('update analysis set distv = ?, author = ?, json = ?, duration = ? where path = ?', @params);
  }
  return $id ? $id : undef;
}

sub bulk_insert {
  my ($self, $bind) = @_;

  my $rows = $self->{_insert_bind} ||= [];
  if (@$rows > 100)  {
    $self->bulk([
      'insert or ignore into analysis (distv, author, json, duration, path) values (?, ?, ?, ?, ?, ?)',
      'update analysis set distv = ?, author = ?, json = ?, duration = ? where path = ?',
    ], $rows);
    @$rows = ();
  }
  push @$rows, [@$bind{qw/distv author json duration path/}]
}

sub finalize_bulk_insert {
  my $self = shift;
  if ($self->{_insert_bind}) {
    $self->bulk([
      'insert or ignore into analysis (distv, author, json, duration, path) values (?, ?, ?, ?, ?, ?)',
      'update analysis set distv = ?, author = ?, json = ?, duration = ? where path = ?',
    ], $self->{_insert_bind});
    delete $self->{_insert_bind};
  }
}

sub fetch_json_by_id {
  my ($self, $id) = @_;
  $self->fetch_1('select json from analysis where id = ?', $id);
}

sub update_json_by_id {
  my ($self, $id, $json) = @_;
  $self->do('update analysis set json = ? where id = ?', $json, $id);
}

sub fetch_next_row {
  my $self = shift;
  unless ($self->{_fetch_row_sth}) {
    my $sth = $self->dbh->prepare('select * from analysis');
    $sth->execute;
    $self->{_fetch_row_sth} = $sth;
  }
  my $row = $self->{_fetch_row_sth}->fetchrow_hashref;
  unless ($row && $row ne '0E0') {
    delete $self->{_fetch_row_sth};
    return;
  }
  return $row;
}

sub fetch_path_by_distv {
  my ($self, $distv) = @_;
  $self->fetch_1('select path from analysis where distv = ?', $distv);
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::Analysis

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
