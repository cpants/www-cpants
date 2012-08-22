package WWW::CPANTS::DB::PrereqModules;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub dbname { 'prereq.db' }
sub schema { return <<'SCHEMA';
create table if not exists prereq (
  distv text,
  prereq text,
  prereq_version text,
  prereq_dist text,
  type integer
);

create index if not exists distv_idx on prereq (distv);

create index if not exists prereq_idx on prereq (prereq);

create index if not exists prereq_dist_idx on prereq (prereq_dist);

create unique index if not exists check_idx on prereq (distv, prereq, prereq_version, type);
SCHEMA
}

sub bulk_insert {
  my ($self, $bind) = @_;

  my $rows = $self->{_insert_bind} ||= [];
  if (@$rows > 100) {
    $self->bulk('insert or replace into prereq (distv, prereq, prereq_version, type) values (?, ?, ?, ?)', $rows);
    @$rows = ();
  }
  push @$rows, [@$bind{qw/distv prereq prereq_version type/}];
}

sub finalize_bulk_insert {
  my $self = shift;
  $self->bulk('insert or replace into prereq (distv, prereq, prereq_version, type) values (?, ?, ?, ?)', $self->{_insert_bind}) if $self->{_insert_bind};
  delete $self->{_insert_bind};
}

sub fetch_all_prereqs {
  my $self = shift;
  $self->fetchall_1('select distinct(prereq) from prereq');
}

sub update_prereq_dist {
  my ($self, $prereq, $dist) = @_;
  $self->do('update prereq set prereq_dist = ? where prereq = ?', $dist, $prereq);
}

sub fetchall_prereq_dists {
  my $self = shift;
  $self->fetchall_1('select distinct(prereq_dist) from prereq');
}

sub fetch_prereqs_of {
  my ($self, $distv) = @_;
  $self->fetchall('select prereq_dist, type from prereq where distv = ? group by prereq_dist', $distv);
}

# -- for tests --

sub fetch_dists_whose_prereq_has_spaces {
  my $self = shift;
  $self->fetchall_1('select distv from prereq where prereq like "% %"');
}

sub fetch_dists_whose_prereq_version_has_spaces {
  my $self = shift;
  $self->fetchall_1('select distv from prereq where prereq_version like "% %"');
}

sub fetch_orphan_prereqs {
  my $self = shift;
  $self->fetchall_1('select prereq from prereq where prereq_dist = ""');
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::PrereqModules

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
