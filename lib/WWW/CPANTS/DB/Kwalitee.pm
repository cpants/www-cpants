package WWW::CPANTS::DB::Kwalitee;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

our @COLS;

sub dbname { 'kwalitee.db' }
sub schema {
  my $self = shift;

  my $base_schema = <<'SCHEMA';
create table if not exists kwalitee (
  analysis_id integer primary key,
  dist text,
  distv text,
  author text,
  released integer,
  removed integer,
  is_latest integer default 0,
  is_cpan integer default 0,
  kwalitee float default 0,
  core_kwalitee float default 0,
  abs_kwalitee integer default 0,
  abs_core_kwalitee integer default 0,
  __KWALITEE__
);

create index if not exists dist_idx on kwalitee (dist);

create index if not exists distv_idx on kwalitee (distv);

create index if not exists author_idx on kwalitee (author);
SCHEMA

  my $kwalitee_schema = join ',', map { "$_ integer default 0" } $self->_kwalitee_indicators;

  $base_schema =~ s/__KWALITEE__/$kwalitee_schema/;
  $base_schema;
}

sub _kwalitee_indicators {
  my $class = shift;

  require WWW::CPANTS::Analyze;
  my $analyzer = WWW::CPANTS::Analyze->new;

  my @indicators;
  for my $module (@{ $analyzer->{kwalitee}->generators }) {
    for my $indicator (@{ $module->kwalitee_indicators }) {
      push @indicators, $indicator->{name};
    }
  }
  @indicators;
}

sub cols { # for bulk insert
  my $self = shift;
  unless (@COLS) {
    my %ignore = map { $_ => 1 } qw(
      analysis_id
      removed
      is_latest
      kwalitee
      core_kwalitee
      abs_kwalitee
      abs_core_kwalitee
      is_prereq
      prereq_matches_use
      build_prereq_matches_use
    );
    my $sth = $self->dbh->prepare('select * from kwalitee');
    @COLS = grep { !$ignore{$_} } @{$sth->{NAME}};
    push @COLS, 'analysis_id';
  }
  @COLS;
}

sub check_schema {
  my $self = shift;

  my ($sql) = $self->dbh->selectrow_array("select sql from sqlite_master where type = 'table' and name = 'kwalitee'");
  $sql =~ s/\s+/ /s;
  my $current = $self->schema;
  $current =~ s/^create table if not exists /CREATE TABLE /;
  $current =~ s/\s+/ /s;
  return $sql eq $current ? 1 : 0;
}

sub bulk_insert {
  my ($self, $bind) = @_;

  my @cols = $self->cols;
  my $rows = $self->{_insert_bind} ||= [];
  if (@$rows > 100)  {
    my $cols = join ',', @cols;
    my $placeholders = substr('?,' x @cols, 0, -1);
    my $set = join ',', map { "$_ = ?" } @cols[0 .. @cols - 2];
    $self->bulk([
      "insert or ignore into kwalitee ($cols) values ($placeholders)",
      "update kwalitee set $set where analysis_id = ?",
    ], $rows);
    @$rows = ();
  }
  push @$rows, [@$bind{@cols}]
}

sub finalize_bulk_insert {
  my $self = shift;
  if ($self->{_insert_bind}) {
    my @cols = $self->cols;
    my $cols = join ',', @cols;
    my $placeholders = substr('?,' x @cols, 0, -1);
    my $set = join ',', map { "$_ = ?" } @cols[0 .. @cols - 2];
    $self->bulk([
      "insert or ignore into kwalitee ($cols) values ($placeholders)",
      "update kwalitee set $set where analysis_id = ?",
    ], $self->{_insert_bind});
    delete $self->{_insert_bind};
  }
}

sub fetchrow {
  my $self = shift;
  if (!$self->{_fetchrow_sth}) {
    $self->{_fetchrow_sth} = $self->dbh->prepare('select * from kwalitee');
    $self->{_fetchrow_sth}->execute;
  }
  $self->{_fetchrow_sth}->fetchrow_hashref;
}

sub update_is_prereq {
  my ($self, $dist, $authors) = @_;

  my $author_params = $self->in_params($authors);
  $self->do("update kwalitee set is_prereq = 1 where dist = ? and author not in ($author_params)", $dist);
}

sub update_prereq_matches_use {
  my ($self, $distv, $prereq_matches, $build_prereq_matches) = @_;
  $self->do('update kwalitee set prereq_matches_use = ?, build_prereq_matches_use = ? where distv = ?', $prereq_matches, $build_prereq_matches, $distv);
}

sub mark_current_latest {
  my $self = shift;
  $self->do('update kwalitee set is_latest = 2 where is_latest > 0');
}

sub unmark_previous_latest {
  my $self = shift;
  $self->do('update kwalitee set is_latest = 0 where is_latest = 2');
}

sub mark_latest {
  my ($self, $dists) = @_;

  my $params = $self->in_params($dists);
  $self->do("update kwalitee set is_latest = 1 where distv in ($params)");
}

sub mark_current_cpan {
  my $self = shift;
  $self->do('update kwalitee set is_cpan = 2 where is_cpan > 0');
}

sub unmark_previous_cpan {
  my $self = shift;
  $self->do('update kwalitee set is_cpan = 0, removed = ? where is_cpan = 2', time);
}

sub mark_cpan {
  my ($self, $dists) = @_;

  my $params = $self->in_params($dists);
  $self->do("update kwalitee set is_cpan = 1 where distv in ($params)");
}

sub update_final_kwalitee {
  my ($self, $row) = @_;

  $self->do("update kwalitee set kwalitee = ?, core_kwalitee = ? where analysis_id = ?", @$row{qw/kwalitee core_kwalitee analysis_id/});
}

sub fetch_authors_stats {
  my $self = shift;

  $self->fetchall('select author as pauseid, count(*) as num_dists, avg(core_kwalitee) as average_core_kwalitee, avg(kwalitee) as average_kwalitee from (select * from kwalitee where is_cpan > 0 group by author, dist order by released) group by author');
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::Kwalitee

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
