package WWW::CPANTS::Page::Dist::UsedBy;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Kwalitee;
use WWW::CPANTS::Utils;

sub load_data {
  my ($class, $name) = @_;

  my $kwalitee_db = db('Kwalitee');
  my $dist = $kwalitee_db->fetch_distv($name);
  return unless $dist && $dist->{distv};

  my $dependents = db('PrereqModules')->fetch_dependents($dist->{dist});
  my $deps = $kwalitee_db->fetch_latest_dists(@$dependents);

  my %data = (
    dist => $dist,
    deps => $deps,
  );
  return \%data;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Dist::UsedBy

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
