package WWW::CPANTS::DB::DistDependents;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub _columns {(
  [dist => 'text primary key not null'],
  [dependents => 'text'],
  [status => 'integer default 0'],
)}

# - currently for testing only -

sub fetch_dependents {
  my ($self, $dist) = @_;
  my $res = $self->fetch_1("select dependents from dist_dependents where dist = ?", $dist);
  return $res ? [split ',', $res] : [];
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::DistDependents

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 fetch_dependents

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
