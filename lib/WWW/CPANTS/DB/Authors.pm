package WWW::CPANTS::DB::Authors;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub dbname { 'authors.db' }
sub schema { return <<'SCHEMA';
create table if not exists authors (
  pauseid text primary key,
  name text,
  email text,
  average_kwalitee float default 0,
  average_core_kwalitee float default 0,
  num_dists integer default 0,
  rank integer default 0
);

create index if not exists average_kwalitee_idx on authors (average_kwalitee);

create index if not exists rank_idx on authors (rank, num_dists);
SCHEMA
}

sub bulk_insert {
  my ($self, $bind) = @_;

  my $rows = $self->{_insert_bind} ||= [];
  if (@$rows > 100) {
    $self->bulk([
      'insert or ignore into authors (name, email, pauseid) values (?, ?, ?)',
      'update authors set name = ?, email = ? where pauseid = ?',
    ], $rows);
    @$rows = ();
  }
  push @$rows, [@$bind{qw/name email pauseid/}];
}

sub finalize_bulk_insert {
  my $self = shift;

  if ($self->{_insert_bind}) {
    $self->bulk([
      'insert or ignore into authors (name, email, pauseid) values (?, ?, ?)',
      'update authors set name = ?, email = ? where pauseid = ?',
    ], $self->{_insert_bind});
    delete $self->{_insert_bind};
  }
}

sub next_pauseid {
  my $self = shift;
  unless ($self->{_next_sth}) {
    $self->{_next_sth} = $self->dbh->prepare('select pauseid from authors');
    $self->{_next_sth}->execute;
  }
  my ($id) = $self->{_next_sth}->fetchrow_array;
  unless ($id) {
    delete $self->{_next_sth};
  }
  return $id
}

sub update_authors_stats {
  my ($self, $rows) = @_;
  $self->bulk('update authors set num_dists = ?, average_kwalitee = ?, average_core_kwalitee = ? where pauseid = ?', [map { [@$_{qw/num_dists average_kwalitee average_core_kwalitee pauseid/}] } @$rows]);
  $self->_update_ranking;
}

sub _update_ranking {
  my $self = shift;

  my $rows = $self->fetchall('select pauseid, average_core_kwalitee, num_dists from authors where num_dists > 0 order by average_core_kwalitee desc');

  my ($ct_many, $ct_few, $rank_many, $rank_few, $val_many, $val_few) = (0, 0, 0, 0, 0, 0);
  my @updates;
  for (@$rows) {
    if ($_->{num_dists} >= 5) {
      $ct_many++;
      if (!$val_many or $val_many > $_->{average_core_kwalitee}) {
        $rank_many = $ct_many;
        $val_many = $_->{average_core_kwalitee};
      }
      push @updates, [$rank_many, $_->{pauseid}];
    }
    else {
      $ct_few++;
      if (!$val_few or $val_few > $_->{average_core_kwalitee}) {
        $rank_few = $ct_few;
        $val_few = $_->{average_core_kwalitee};
      }
      push @updates, [$rank_few, $_->{pauseid}];
    }
  }
  $self->bulk('update authors set rank = ? where pauseid = ?', \@updates);
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::DistAuthors

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
