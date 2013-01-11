package WWW::CPANTS::DB::Kwalitee;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';
use WWW::CPANTS::Kwalitee;
use Time::Piece;

sub _columns {
  my $self = shift;

  return (
    [analysis_id => 'integer not null', {bulk_key => 1}],
    [dist => 'text'],
    [distv => 'text'],
    [author => 'text'],
    [released => 'integer default 0'],
    [removed => 'integer', {no_bulk => 0}],
    [is_latest => 'integer default 0', {no_bulk => 0}],
    [is_cpan => 'integer default 0', {no_bulk => 0}],
    [kwalitee => 'float default 0', {no_bulk => 0}],
    [core_kwalitee => 'float default 0', {no_bulk => 0}],
    [abs_kwalitee => 'integer default 0', {no_bulk => 0}],
    [abs_core_kwalitee => 'integer default 0', {no_bulk => 0}],
    (map {[$_ => 'integer']} $self->_kwalitee_indicators),
  );
}

sub _indices {(
  unique => ['analysis_id'],
  ['dist'],
  ['distv'],
  ['author'],
  ['is_cpan'],
  ['is_latest'],
)}

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

sub _fix_test_data {
  my ($row, $opts) = @_;
  my $id = $row->{analysis_id};
  $row->{dist}  ||= "Dist$id";
  $row->{distv} ||= $row->{dist}."-0.01";
  $row->{author} ||= 'AUTHOR';
  if ($opts->{set_metrics}) {
    unless (kwalitee_metrics()) { save_metrics() }
    for (kwalitee_metrics()) {
      $row->{$_->{name}} = ($_->{name} =~ /^[ehmnu]/) ? 1 : 0;
    }
  }
}

# - Process::Kwalitee::AuthorStats -

sub fetch_author_stats {
  my $self = shift;

  $self->fetchall('select author as pauseid, count(*) as num_dists, avg(core_kwalitee) as average_core_kwalitee, avg(kwalitee) as average_kwalitee from (select * from kwalitee where is_latest > 0 group by author, dist) group by author');
}

# - Process::Kwalitee::FinalKwalitee -

sub update_final_kwalitee {
  my ($self, $row) = @_;

  $self->bulk(update_final_kwalitee => "update kwalitee set kwalitee = ?, core_kwalitee = ? where analysis_id = ?", @$row{qw/kwalitee core_kwalitee analysis_id/});
}

sub finalize_update_final_kwalitee {
  shift->finalize_bulk('update_final_kwalitee');
}

# - Process::Kwalitee::IsCPAN -

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

  my $dbh = $self->dbh;

  if (@$dists > 500) {
    my $placeholders = substr('?,' x 500, 0, -1);
    my $sth = $dbh->prepare("update kwalitee set is_latest = 1 where distv in ($placeholders)");

    while(@$dists > 500) {
      $sth->execute(splice @$dists, 0, 500);
    }
  }

  {
    my $placeholders = substr('?,' x @$dists, 0, -1);
    $dbh->do("update kwalitee set is_latest = 1 where distv in ($placeholders)", undef, @$dists);
  }
}

sub mark_implicit_latest {
  my $self = shift;
  $self->do("update kwalitee set is_latest = 1 where distv in (select distv from kwalitee where is_cpan > 0 group by dist having ifnull(min(is_latest), 0) < 1 and released = max(released))");
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

  my $dbh = $self->dbh;

  if (@$dists > 500) {
    my $placeholders = substr('?,' x 500, 0, -1);
    my $sth = $dbh->prepare("update kwalitee set is_cpan = 1 where distv in ($placeholders)");

    while(@$dists > 500) {
      $sth->execute(splice @$dists, 0, 500);
    }
  }

  {
    my $placeholders = substr('?,' x @$dists, 0, -1);
    $dbh->do("update kwalitee set is_cpan = 1 where distv in ($placeholders)", undef, @$dists);
  }
}

# - Process::Kwalitee::IsPrereq -

sub update_is_prereq {
  my ($self, $id, $is_prereq) = @_;

  $self->bulk(update_is_prereq => "update kwalitee set is_prereq = ? where analysis_id = ?", $is_prereq, $id);
}

sub finalize_update_is_prereq {
  shift->finalize_bulk('update_is_prereq');
}

# - Process::Kwalitee::PrereqMatchesUse -

sub fetch_all_prereq_matches_use {
  my $self = shift;
  $self->fetchall("select distv, prereq_matches_use, build_prereq_matches_use from kwalitee");
}

sub update_prereq_matches_use {
  my ($self, $distv, $prereq_matches, $build_prereq_matches) = @_;
  $self->bulk(update_prereq_matches_use => 'update kwalitee set prereq_matches_use = ?, build_prereq_matches_use = ? where distv = ?', $prereq_matches, $build_prereq_matches, $distv);
}

sub finalize_update_prereq_matches_use {
  shift->finalize_bulk('update_prereq_matches_use');
}

# - Page::Author -

sub fetch_author_kwalitee {
  my ($self, $id) = @_;

  $self->fetchall("select * from (select * from kwalitee where author = ? and is_cpan > 0 order by released asc) group by dist", $id);
}

# - Page::Dists -

sub search_dists {
  my ($self, $name) = @_;

  $self->fetchall_1("select dist from kwalitee where is_latest > 0 and dist like ? order by dist", "$name%");
}

# - Page::Kwalitee -

sub fetch_overview {
  my $self = shift;

  $self->check_schema;

  my @sums;
  for my $metric (kwalitee_metrics()) {
    my $name = $metric->{name};
    push @sums, "sum(case when $name = 0 then 1 else 0 end) as backpan_$name";
    push @sums, "sum(case when (is_cpan > 0 and $name = 0) then 1 else 0 end) as cpan_$name";
    push @sums, "sum(case when (is_latest > 0 and $name = 0) then 1 else 0 end) as latest_$name";
  }
  $self->fetch(qq{
    select
      sum(1) as backpan_total,
      sum(case when is_cpan > 0 then 1 else 0 end) as cpan_total,
      sum(case when is_latest > 0 then 1 else 0 end) as latest_total,
  }.join(',',@sums).qq{
    from kwalitee
  });
}

# - Page::Kwalitee::Indicator -

sub fetch_indicator_stats {
  my $self = shift;

  $self->check_schema;

  my $year = Time::Piece->new->year;
  my @items;
  my @metrics = map { $_->{name} } kwalitee_metrics();
  for my $name (@metrics) {
    push @items, "sum(case when $name = 0 then 1 else 0 end) as 'backpan_$name'";
    push @items, "sum(case when ($name = 0 and is_cpan > 0) then 1 else 0 end) as 'cpan_$name'";
    push @items, "sum(case when ($name = 0 and is_latest > 0) then 1 else 0 end) as 'latest_$name'";
    push @items, "sum(1) as 'backpan_total'";
    push @items, "sum(case when is_cpan > 0 then 1 else 0 end) as 'cpan_total'";
    push @items, "sum(case when is_latest > 0 then 1 else 0 end) as 'latest_total'";
  }
  $self->fetchall("select strftime('%Y', released, 'unixepoch') + 0 as year, ".join(',', @items)." from kwalitee where year between (? + 0) and (? + 0) group by year", $year - 9, $year);
}

sub fetch_latest_failing_dists {
  my ($self, $indicator) = @_;
  die "needs kwalitee indicator\n" unless $indicator;
  my $name = $self->dbh->quote_identifier($indicator);
  $self->fetchall("select distv, author, released from kwalitee where $name = 0 and is_latest > 0 order by released desc limit 100");
}

# - Page::Dist::Chart -

sub fetch_dist_history {
  my ($self, $dist, $limit) = @_;

  $limit = $limit ? "limit $limit" : "";
  $self->fetchall("select distv, author, strftime('%Y-%m-%d', released, 'unixepoch') as date, is_cpan, kwalitee, core_kwalitee from kwalitee where dist = ? order by released desc $limit", $dist);
}

# - Page::Author::Feed -

sub fetch_author_history {
  my ($self, $author, $limit) = @_;

  $limit ||= 10;
  $self->fetchall("select distv, released, is_cpan, kwalitee, core_kwalitee from kwalitee where author = ? order by released desc limit $limit", $author);
}

# - Page::Dist::Overview, Page::Dist::Metadata, Page::Dist::Prereq, Page::Dist::Provides, Page::Dist::UsedBy -

sub fetch_distv {
  my ($self, $dist_or_distv) = @_;

  $self->fetch("select * from kwalitee where (distv = ?) or (dist = ? and is_latest = 1)", $dist_or_distv, $dist_or_distv);
}

# - Page::Dist::Prereq, Page::Dist::UsedBy -

sub fetch_latest_dists {
  my ($self, @dists) = @_;

  my $params = $self->_in_params(@dists);
  $self->fetchall("select * from kwalitee where dist in ($params) and is_latest = 1 order by dist");
}

# - Page::Ranking::HallOfFame -

sub fetch_most_kwalitative_dists {
  my $self = shift;

  $self->fetchall("select dist, author, kwalitee from kwalitee where is_latest > 0 and kwalitee = (select max(kwalitee) from kwalitee where is_latest > 0) order by dist");
}

# - Page::Recent -

sub fetch_distv_kwalitee {
  my ($self, $distvs) = @_;

  my $params = $self->_in_params($distvs);
  $self->fetchall("select distv, kwalitee from kwalitee where distv in ($params)");
}

# - for testing only -

sub fetch_latest_dist {
  my ($self, $dist) = @_;

  $self->fetch("select * from kwalitee where dist = ? and is_latest = 1", $dist);
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::Kwalitee

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 fetch_all_prereq_matches_use
=head2 fetch_author_stats
=head2 fetch_author_kwalitee
=head2 fetch_dist_history
=head2 fetch_distv
=head2 fetch_latest_dist
=head2 fetch_latest_dists
=head2 fetch_latest_failing_dists
=head2 fetch_most_kwalitative_dists
=head2 fetch_overview
=head2 fetch_indicator_stats
=head2 mark_cpan
=head2 mark_current_cpan
=head2 mark_current_latest
=head2 mark_implicit_latest
=head2 mark_latest
=head2 search_dists
=head2 fetch_distv_kwalitee
=head2 unmark_previous_cpan
=head2 unmark_previous_latest
=head2 update_final_kwalitee
=head2 update_is_prereq
=head2 update_prereq_matches_use
=head2 finalize_update_final_kwalitee
=head2 finalize_update_is_prereq
=head2 finalize_update_prereq_matches_use

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
