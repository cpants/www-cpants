package WWW::CPANTS::DB::Queue;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub _columns {(
  [id => 'integer primary key autoincrement not null', {no_bulk => 1}],
  [path => 'text unique', {bulk_key => 1}],
  [status => 'integer default 0'],
  [started_at => 'integer', {no_bulk => 1}],
  [ended_at => 'integer', {no_bulk => 1}],
)}

sub fetch_first_id {
  my $self = shift;
  $self->fetch_1('select id from queue where status = 0 limit 1');
}

sub fetch_by_path {
  my ($self, $path) = @_;
  $self->fetch("select * from queue where path = ?", $path);
}

sub mark {
  my $self = shift;
  my $id;

  # XXX: efficiency!
  $self->dbh->sqlite_update_hook(sub {(undef, undef, undef, $id) = @_});
  $self->do("update queue set status = 1, started_at = ?, ended_at = 0 where id in (select id from queue where status = 0 limit 1)", time);
  $id;
}

sub fetch_path {
  my ($self, $id) = @_;
  $self->fetch_1('select path from queue where id = ?', $id);
}

sub mark_done {
  my ($self, $id) = @_;
  $self->do('update queue set status = 2, ended_at = ? where id = ?', time, $id);
}

sub count_queued_items {
  my $self = shift;
  $self->fetch_1("select count(*) from queue where status = 0");
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::Queue

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 count_queued_items
=head2 fetch_first_id
=head2 fetch_path
=head2 fetch_by_path
=head2 mark
=head2 mark_done

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
