package WWW::CPANTS::DB::Uploads;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';
use Scope::OnExit;

sub _columns {(
  [path => 'text primary key', {bulk_key => 1}],
  [type => 'text'],
  [author => 'text'],
  [dist => 'text'],
  [distv => 'text'],
  [version => 'text'],
  [filename => 'text'],
  [released => 'integer'],
  [removed => 'integer'],
  [year => 'integer'],
)}

sub _indices {(
  ['released'],
  ['dist'],
  ['distv'],
  ['year'],
)}

sub _fix_test_data {
  my $row = shift;

  if ($row->{path}) {
    require CPAN::DistnameInfo;
    my $dist = CPAN::DistnameInfo->new($row->{path});
    $row->{author}   = $dist->cpanid;
    $row->{dist}     = $dist->dist;
    $row->{distv}    = $dist->distvname;
    $row->{version}  = $dist->version;
    $row->{filename} = $dist->filename;
  }
  else {
    $row->{author} ||= 'AUTHOR';
    $row->{distv} = join '-', $row->{dist}, $row->{version};
    $row->{path} = join '/',
      substr($row->{author}, 0, 1),
      substr($row->{author}, 0, 2),
      $row->{author},
      $row->{distv}.'.tar.gz';
  }
  $row->{year} ||= Time::Piece->new($row->{released})->year;
  $row;
}

sub fetch_current_type {
  my ($self, $path) = @_;
  $self->fetch_1('select type from uploads where path = ?', $path);
}

sub update_type {
  my ($self, $type, $path) = @_;
  my $sth = $self->{_update_type_sth}
        ||= $self->dbh->prepare(qq{
              update uploads
              set type = ?, removed = ?
              where path = ?
            });
  my $removed = $type eq 'backpan' ? time : undef;
  $sth->execute($type, $removed, $path);
}

sub finalize_update_type {
  my $self = shift;
  delete $self->{_update_type_sth};
}

sub cpan_dists {
  my $self = shift;
  $self->fetchall_1('select distv from uploads where type = "cpan"');
}

sub latest_dists {
  my $self = shift;
  $self->fetchall_1('select distv from uploads where type = "cpan" group by dist having max(released)');
}

sub latest_stable_dists {
  my $self = shift;
  $self->fetchall_1('select distv from uploads where type = "cpan" and version not like "%\\_%" escape "\\" and version not like "%-%" group by dist having max(released)');
}

# - Page::API::Uploads -

sub fetch_dist_version {
  my ($self, $dist, $version) = @_;

  my $sql = "select type, author, dist, version, filename, released from uploads where dist = ?";
  my @bind = ($dist);
  if ($version && $version =~ /^[0-9._]+$/) {
    push @bind, $version;
    $sql .= " and version <= ?";
  }
  $sql .= " order by released desc limit 1";

  $self->fetch($sql, @bind);
}

# - Page::Stats::Authors -

sub count_active_authors_per_year {
  my $self = shift;
  $self->fetchall("select year, count(distinct(author)) as authors from uploads group by year order by year");
}

# - Page::Stats::Uploads -

sub count_distinct_dists {
  my ($self, $type) = @_;
  if ($type) {
  $self->fetch_1("select count(distinct(dist)) from uploads where type = ?", $type);
  }
  else { # may be slow
    $self->fetch_1("select count(distinct(dist)) from uploads");
  }
}

sub count_uploads {
  my $self = shift;
  $self->fetch_1("select count(*) from uploads");
}

sub count_uploads_per_year {
  my $self = shift;
  $self->fetchall(qq{
    select
      u.year,
      u.uploads,
      n.new_uploads,
      u.is_cpan
    from (
      select
        year,
        count(dist) as uploads,
        sum(case when type = 'cpan' then 1 else 0 end) as is_cpan
      from uploads group by year
    ) as u, (
      select
        year,
        count(dist) as new_uploads
      from (
        select
          year,
          dist
        from uploads group by dist having min(released)
      ) group by year
    ) as n
    where u.year = n.year order by u.year
  });
}

sub fetch_most_often_uploaded {
  my $self = shift;

  $self->do('create temp table t (dist, uploads, authors)');
  on_scope_exit { $self->do('drop table if exists t') };
  $self->do('create index idx_uploads on t (uploads)');
  $self->do(q{
    insert into t
      select
        dist,
        count(*) as uploads,
        group_concat(distinct(author)) as authors
      from uploads
      group by dist order by uploads desc limit 130
  });
  $self->fetchall(q{
    select dist, authors, r.uploads, r.rank from t, (
      select
        uploads,
        (select count(*) from t where uploads > t0.uploads) + 1 as rank
      from t as t0
      group by uploads order by uploads desc
    ) as r 
    where r.rank <= 100 and r.uploads = t.uploads
    order by r.rank, dist
  });
}

sub fetch_recent_uploads {
  my ($self, $since) = @_;
  $self->fetchall("select distv, author, strftime('%Y-%m-%d', released, 'unixepoch') as date from uploads where released > ? order by released desc", $since);
}

sub fetch_recent_versions {
  my ($self, $dist, $limit) = @_;
  $limit = $limit ? "limit $limit" : "";
  $self->fetchall("select distv, version, author, strftime('%Y-%m-%d', released, 'unixepoch') as date from uploads where dist = ? order by released desc $limit", $dist);
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::Uploads

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 cpan_dists
=head2 latest_dists
=head2 latest_stable_dists
=head2 count_active_authors_per_year
=head2 count_distinct_dists
=head2 count_uploads
=head2 count_uploads_per_year
=head2 fetch_most_often_uploaded
=head2 fetch_current_type
=head2 fetch_recent_uploads
=head2 fetch_recent_versions
=head2 finalize_update_type
=head2 update_type

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
