package WWW::CPANTS::DB::Errors;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub _columns {(
  [distv => 'text', {bulk_key => 1}],
  [category => 'text', {bulk_key => 1}],
  [error => 'text'],
  [status => 'integer default 0'],
)}

sub _indices {(
  unique => ['distv', 'category'],
)}

# - Process::Kwalitee::PrereqMatchesUse -

sub mark {
  my $self = shift;
  if (@_) {
    my $params = $self->_in_params(@_);
    $self->do("update errors set status = 1 where category in ($params)");
  }
  else {
    $self->do("update errors set status = 1");
  }
  $self->{marked} = 1;
}

sub unmark {
  my $self = shift;
  if (@_) {
    my $params = $self->_in_params(@_);
    $self->do("delete from errors where category in ($params) and status = 1");
  }
  else {
    $self->do("delete from errors where status = 1");
  }
  delete $self->{marked};
}

# - currently for testing only -

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

=head2 fetch_distv_errors
=head2 fetch_category_errors
=head2 mark
=head2 unmark

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
