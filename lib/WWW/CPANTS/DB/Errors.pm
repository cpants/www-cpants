package WWW::CPANTS::DB::Errors;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub dbname { 'errors.db' }
sub schema { return <<'SCHEMA';
create table if not exists errors (
  distv text,
  category text,
  error text
);

create index if not exists category_idx on errors (category);

create unique index if not exists check_idx on errors (distv, category);
SCHEMA
}

sub bulk_insert {
  my ($self, $bind) = @_;

  my $rows = $self->{_insert_bind} ||= [];
  if (@$rows > 100) {
    $self->bulk('insert or replace into errors (distv, category, error) values (?, ?, ?)', $rows);
    @$rows = ();
  }
  push @$rows, [@$bind{qw/distv category error/}];
}

sub finalize_bulk_insert {
  my $self = shift;
  $self->bulk('insert or replace into errors (distv, category, error) values (?, ?, ?)', $self->{_insert_bind}) if $self->{_insert_bind};
  delete $self->{_insert_bind};
}

sub fetch_distv_errors {
  my ($self, $distv) = @_;
  $self->fetchall('select category, error from errors where distv = ?', $distv);
}

sub fetch_category_errors {
  my ($self, $category) = @_;
  $self->fetchall('select distv, error from errors where category = ?', $category);
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::Errors

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
