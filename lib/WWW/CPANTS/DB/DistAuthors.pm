package WWW::CPANTS::DB::DistAuthors;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub _columns {(
  [dist => 'text'],
  [author => 'text'],
)}

sub _indices {(
  unique => ['dist', 'author'],
)}

# - currently for testing only -

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

=head2 fetch_authors

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
