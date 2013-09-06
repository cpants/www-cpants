package WWW::CPANTS::DB::Authors;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub _columns {(
  [pauseid => 'text primary key not null', {bulk_key => 1}],
  [name => 'text'],
  [email => 'text'],
  [average_kwalitee => 'float default 0', {no_bulk => 1}],
  [average_core_kwalitee => 'float default 0', {no_bulk => 1}],
  [num_dists => 'integer default 0', {no_bulk => 1}],
  [rank => 'integer default 0', {no_bulk => 1}],
  [liga => 'integer default 0', {no_bulk => 1}],
  [sort_id => 'integer default 0', {no_bulk => 1}],
  [status => 'integer default 0'],
)}

# - Process::Kwalitee::AuthorStats -

sub update_author_stats {
  my ($self, $rows) = @_;

  my $dbh = $self->dbh;
  my $sth = $dbh->prepare('update authors set num_dists = ?, average_kwalitee = ?, average_core_kwalitee = ? where pauseid = ?');

  my $ct = 0;
  $dbh->begin_work;
  for (@$rows) {
    $sth->execute(@$_{qw/num_dists average_kwalitee average_core_kwalitee pauseid/});
    unless (++$ct % 1000) {
      $dbh->commit;
      $dbh->begin_work;
    }
  }
  $dbh->commit;

  $self->_update_ranking;
}

sub _update_ranking {
  my $self = shift;

  my $dbh = $self->dbh;
  my $sth = $dbh->prepare('update authors set rank = ?, liga = ?, sort_id = ? where pauseid = ?');

  my $rows = $self->fetchall('select pauseid, average_core_kwalitee, num_dists from authors where num_dists > 0 order by average_core_kwalitee desc, num_dists desc, pauseid');

  my ($ct_many, $ct_few, $rank_many, $rank_few, $val_many, $val_few) = (0, 0, 0, 0, 0, 0);
  my $ct = 0;
  $dbh->begin_work;
  for (@$rows) {
    if ($_->{num_dists} >= 5) {
      $ct_many++;
      if (!$val_many or $val_many > $_->{average_core_kwalitee}) {
        $rank_many = $ct_many;
        $val_many = $_->{average_core_kwalitee};
      }
      $sth->execute($rank_many, 1, $ct_many, $_->{pauseid});
    }
    else {
      $ct_few++;
      if (!$val_few or $val_few > $_->{average_core_kwalitee}) {
        $rank_few = $ct_few;
        $val_few = $_->{average_core_kwalitee};
      }
      $sth->execute($rank_few, 0, $ct_few, $_->{pauseid});
    }
    unless (++$ct % 1000) {
      $dbh->commit;
      $dbh->begin_work;
    }
  }
  $dbh->commit;
}

# - Page::Ranking::FiveOrMore, Page::Ranking::LessThanFive -

sub _fetch_ranking {
  my ($self, $page, $liga) = @_;
  $page ||= 1;
  my $limit = 100;

  my $rows = $self->fetchall('select * from authors where sort_id between ? and ? and liga = ? order by sort_id, num_dists desc, pauseid', ($page - 1) * $limit + 1, $page * $limit + 1, $liga);

  my $prev = $page > 1 ? $page - 1 : undef;
  my $next;
  if (@$rows == $limit + 1) {
    pop @$rows;
    $next = $page + 1;
  }

  return {
    rows => $rows,
    prev => $prev,
    next => $next,
  };
}

sub fetch_five_or_more_dists_ranking {
  my ($self, $page) = @_;
  $self->_fetch_ranking($page, 1);
}

sub fetch_less_than_five_dists_ranking {
  my ($self, $page) = @_;
  $self->_fetch_ranking($page, 0);
}

# - Page::Authors -

sub search_authors { # SLOW
  my ($self, $id) = @_;

  $self->fetchall("select pauseid, name from authors where pauseid like ? order by pauseid", "$id%");
}

# - Page::Author -

sub fetch_author {
  my ($self, $id) = @_;
  $self->fetch("select * from authors where pauseid = ?", $id);
}

# - Page::Stats::Authors -

sub count_authors {
  my $self = shift;
  $self->fetch_1("select count(*) from authors");
}

sub count_contributed_authors {
  my $self = shift;
  $self->fetch_1("select count(*) from authors where num_dists > 0");
}

sub fetch_most_contributed_authors {
  my $self = shift;
  $self->fetchall(qq{
    select
      r.rank,
      r.num_dists,
      pauseid,
      name
    from authors, (
      select num_dists, (select count(*) from authors where num_dists > a.num_dists) + 1 as rank
      from authors as a
      group by num_dists
      order by num_dists desc
    ) as r
    where r.rank <= 100 and authors.num_dists = r.num_dists
    order by r.rank, pauseid
  });
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::Authors

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 update_author_stats
=head2 fetch_five_or_more_dists_ranking
=head2 fetch_less_than_five_dists_ranking
=head2 search_authors
=head2 fetch_author
=head2 count_authors
=head2 count_contributed_authors
=head2 fetch_most_contributed_authors

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
