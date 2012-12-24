package WWW::CPANTS::Page::API::Uploads;

use strict;
use warnings;
use WWW::CPANTS::DB;

sub load_data {
  my ($class, $dists) = @_;

  my $db = db_r('Uploads');
  my @data;
  for my $dist (@$dists) {
    push @data, $db->fetch_dist_version(split ',', $dist);
  }

  \@data;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::API::Uploads

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 load_data

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
