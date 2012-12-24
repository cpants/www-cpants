package WWW::CPANTS::Page::Dist::Provides;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Kwalitee;
use WWW::CPANTS::Utils;

sub load_data {
  my ($class, $name) = @_;

  my $dist = db('Kwalitee')->fetch_distv($name);
  return unless $dist && $dist->{distv};

  my $modules = db('DistModules')->fetch_dist_modules($dist->{distv});

  my %data = (
    dist => $dist,
    modules => $modules,
  );
  return \%data;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Dist::Provides

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
