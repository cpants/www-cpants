package WWW::CPANTS::DB::PrereqModules;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';
use Scope::OnExit;

sub _columns {(
  [dist => 'text'],
  [distv => 'text', {bulk_key => 1}],
  [author => 'text'],
  [prereq => 'text', {bulk_key => 1}],
  [prereq_version => 'text', {bulk_key => 1}],
  [prereq_dist => 'text'],
  [type => 'integer', {bulk_key => 1}],
)}

sub _indices {(
  ['distv'],
  ['prereq'],
  ['prereq_dist'],
  unique => [qw/distv prereq prereq_version type/],
)}

# - Process::Kwalitee::DistDependents -

sub fetch_all_prereq_dists {
  my $self = shift;
  $self->fetchall_1('select distinct(prereq_dist) from prereq_modules');
}

# - Process::Kwalitee::DistDependents -

sub fetch_dependents {
  my ($self, $dists) = @_;
  my $params = $self->_in_params($dists);
  $self->attach('Uploads');
  on_scope_exit { $self->detach('Uploads') };
  $self->fetchall("select prereq_dist, group_concat(distinct(p.dist)) as dependents from prereq_modules as p join (select dist from uploads group by dist having type = 'cpan') as u on p.dist = u.dist where prereq_dist in ($params) group by prereq_dist");
}

# - Process::Kwalitee::IsPrereq -

sub fetch_first_dependent_by_others {
  my ($self, $dist, $author) = @_;
  $self->fetch_1("select dist from prereq_modules where prereq_dist = ? and author != ? limit 1", $dist, $author);
}

# - Process::Kwalitee::PrereqDist -

sub fetch_all_prereqs {
  my $self = shift;
  $self->fetchall('select distinct(prereq), prereq_dist from prereq_modules');
}

sub update_prereq_dist {
  my ($self, $prereq, $dist) = @_;
  $self->bulk(update_prereq_dist => 'update prereq_modules set prereq_dist = ? where prereq = ?', $dist, $prereq);
}

sub finalize_update_prereq_dist {
  shift->finalize_bulk('update_prereq_dist');
}

sub update_stray_prereq_dists {
  my ($self, $prereqs) = @_;
  while (my @p = splice @$prereqs, 0, 100) {
    my $params = $self->_in_params(\@p);
    $self->do("update prereq_modules set prereq_dist = '' where prereq in ($params)");
  }
}

# - Process::Kwalitee::PrereqMatchesUse, Page::Dist::Prereq -

sub fetch_prereqs_of {
  my ($self, $distv) = @_;
  $self->fetchall('select * from prereq_modules where distv = ?', $distv);
}

# - Page::Stats::Dependencies

sub fetch_stats_of_required {
  my $self = shift;

  $self->attach('Kwalitee');
  on_scope_exit { $self->detach('Kwalitee') };
  $self->fetchall(q{
    select cat, count(cat) as count, min(c.count) as sort
    from (
      select (
        case
  } . join("\n", map {
        qq{when p.count >= $_ then ">= $_"}
  } (1000, 100, 50, 30, 20, 10, 7, 5, 3, 2, 1)) . q{
          else "0"
        end
      ) as cat, p.count
      from (
        select dist
        from kwalitee.kwalitee
        where is_latest > 0 and dist != 'perl'
      ) as k
      left join (
        select
          prereq_dist,
          count(*) as count
        from
          prereq_modules as p,
          kwalitee.kwalitee as k
        where k.is_latest > 0 and p.distv = k.distv
        group by prereq_dist
      ) as p on (k.dist = p.prereq_dist)
    ) as c
    group by cat order by sort desc
  });
}

sub fetch_stats_of_requires {
  my $self = shift;

  $self->attach('Kwalitee');
  on_scope_exit { $self->detach('Kwalitee') };
  $self->fetchall(q{
    select cat, count(cat) as count, min(c.count) as sort
    from (
      select (
        case
  } . join("\n", map {
        qq{when p.count >= $_ then ">= $_"}
  } (1000, 100, 50, 30, 20, 15, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)) . q{
          else "0"
        end
      ) as cat, p.count
      from (
        select distv
        from kwalitee.kwalitee
        where is_latest > 0
      ) as k
      left join (
        select p.distv, count(*) as count
        from
          prereq_modules as p,
          kwalitee.kwalitee as k
        where k.is_latest > 0 and p.distv = k.distv
        group by p.distv
      ) as p on (k.distv = p.distv)
    ) as c
    group by cat order by sort desc
  });
}

sub fetch_most_required_dists {
  my $self = shift;

  $self->attach('Kwalitee');
  $self->do('create temp table t (prereq_dist, count)');
  on_scope_exit {
    $self->detach('Kwalitee');
    $self->do('drop table t');
  };
  $self->do('create index idx_count on t (count)');
  $self->do(q{
    insert into t
      select prereq_dist, count(prereq_dist) as count
      from (
        select prereq_dist
        from prereq_modules as p, kwalitee.kwalitee as k
        where k.is_latest > 0 and p.distv = k.distv
          and p.prereq_dist != '' and p.prereq_dist != 'perl'
      ) group by prereq_dist order by count desc limit 130
  });
  $self->fetchall(q{
    select
      prereq_dist,
      count,
      (select count(*) from t where count > t0.count) + 1 as rank
    from t as t0
    where rank <= 100
    order by rank, prereq_dist
  });
}

sub fetch_dists_that_requires_most {
  my $self = shift;

  $self->attach('Kwalitee');
  $self->do('create temp table t (distv, count)');
  on_scope_exit {
    $self->detach('Kwalitee');
    $self->do('drop table t');
  };
  $self->do('create index idx_count on t (count)');
  $self->do(q{
    insert into t
      select distv, count(distv) as count
      from (
        select k.distv
        from prereq_modules as p, kwalitee.kwalitee as k
        where
          substr(k.distv, 1, 5) != "Task-" and
          k.is_latest > 0 and p.distv = k.distv
      ) group by distv order by count desc limit 130
  });
  $self->fetchall(q{
    select
      distv,
      count,
      (select count(*) from t where count > t0.count) + 1 as rank
    from t as t0
    where rank <= 100
    order by rank, distv
  });
}

# -- for tests --

sub fetch_dists_whose_prereq_has_spaces {
  my $self = shift;
  $self->fetchall_1('select distv from prereq_modules where prereq like "% %"');
}

sub fetch_dists_whose_prereq_version_has_spaces {
  my $self = shift;
  $self->fetchall_1('select distv from prereq_modules where prereq_version like "% %"');
}

sub fetch_stray_prereqs {
  my $self = shift;
  $self->fetchall_1('select prereq from prereq_modules where prereq_dist = ""');
}

sub num_of_dependents_by_others {
  my ($self, $dist, $author) = @_;
  $self->fetch_1("select count(*) from prereq_modules where prereq_dist = ? and author != ?", $dist, $author);
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::PrereqModules

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 fetch_all_prereqs
=head2 fetch_all_prereq_dists
=head2 fetch_dependents
=head2 fetch_dists_whose_prereq_has_spaces
=head2 fetch_dists_whose_prereq_version_has_spaces
=head2 fetch_first_dependent_by_others
=head2 fetch_stray_prereqs
=head2 fetch_prereqs_of
=head2 fetchall_prereq_dists
=head2 num_of_dependents_by_others
=head2 update_prereq_dist
=head2 finalize_update_prereq_dist
=head2 update_stray_prereq_dists
=head2 fetch_stats_of_required
=head2 fetch_stats_of_requires
=head2 fetch_most_required_dists
=head2 fetch_dists_that_requires_most

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
