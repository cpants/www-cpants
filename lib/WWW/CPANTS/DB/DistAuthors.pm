package WWW::CPANTS::DB::DistAuthors;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub dbname { 'dist_authors.db' }
sub schema { return <<'SCHEMA';
create table if not exists dist_authors (
  dist text,
  author text
);

create index if not exists dist_idx on dist_authors (dist);

create index if not exists author_idx on dist_authors (author);

create unique index if not exists dist_author_idx on dist_authors (dist, author);
SCHEMA
}

sub bulk_insert {
  my ($self, $bind) = @_;

  my $rows = $self->{_insert_bind} ||= [];
  if (@$rows > 100) {
    $self->bulk('insert or ignore into dist_authors (dist, author) values (?, ?)', $rows);
    @$rows = ();
  }
  push @$rows, [@$bind{qw/dist author/}];
}

sub finalize_bulk_insert {
  my $self = shift;
  $self->bulk('insert or ignore into dist_authors (dist, author) values (?, ?)', $self->{_insert_bind}) if $self->{_insert_bind};
  delete $self->{_insert_bind};
}

sub fetch_authors {
  my ($self, $dist) = @_;
  $self->fetchall_1('select author from dist_authors where dist = ?', $dist);
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
