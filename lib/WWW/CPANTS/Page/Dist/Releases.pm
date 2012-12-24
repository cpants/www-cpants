package WWW::CPANTS::Page::Dist::Releases;

use strict;
use warnings;
use WWW::CPANTS::DB;

sub load_data {
  my ($class, $name) = @_;

  my $db = db_r('Kwalitee');
  my $dist = $db->fetch_distv($name) or return;
  $name = $dist->{dist};
  ($dist->{version} = $dist->{distv}) =~ s/^$name\-//;

  my $history = $db->fetch_dist_history($name);
  for (@$history) {
    ($_->{version} = $_->{distv}) =~ s/^$name\-//;
  }

  return {
    dist => $dist,
    releases => $history,
  };
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Dist::Releases

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
