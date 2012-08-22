package WWW::CPANTS::DB::Queue;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub dbname { 'queue.db' }
sub schema { return <<'SCHEMA';
create table if not exists queue (
  id integer primary key autoincrement,
  path text unique,
  status integer default 0,
  started_at integer,
  ended_at integer
);
SCHEMA
}

sub enqueue {
  my $self = shift;
  my $conflict =  $self->{force} ? "replace" : "ignore";

  $self->bulk("insert or $conflict into queue (path, status) values (?, 0)", shift);
}

sub get_first_id {
  my $self = shift;
  $self->fetch_1('select id from queue where status = 0 limit 1');
}

sub mark {
  my ($self, %opts) = @_;
  my $id;

  # XXX: efficiency!
  $self->dbh->sqlite_update_hook(sub {(undef, undef, undef, $id) = @_});
  $self->txn(sub {
    shift->do("update queue set status = 1, started_at = ?, ended_at = '' where id in (select id from queue where status = 0 limit 1)", time);
  });
  $id;
}

sub get_path {
  my ($self, $id) = @_;
  $self->fetch_1('select path from queue where id = ?', $id);
}

sub mark_done {
  my ($self, $id) = @_;
  $self->txn(sub {
    shift->do('update queue set status = 2, ended_at = ? where id = ?', time, shift)
  }, $id);
}

sub dequeue {
  my ($self, $code) = @_;
  my $id = $self->mark(@_) or return;
  my $path = $self->get_path($id);
  $code->($path) and $self->mark_done($id);
  return 1;
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::Queue

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
