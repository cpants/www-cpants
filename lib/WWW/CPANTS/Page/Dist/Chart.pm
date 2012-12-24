package WWW::CPANTS::Page::Dist::Chart;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Utils;

sub load_data {
  my ($class, $name) = @_;

  my $db = db_r('Kwalitee');

  my $dist = $db->fetch_distv($name) or return;
  $name = $dist->{dist};
  my $history = db('Kwalitee')->fetch_dist_history($name, 10);

  my (@dates, @kwalitee);
  for my $dist (reverse @$history) {
    my $date = $dist->{date};
    (my $version = $dist->{distv}) =~ s/^$name\-//;
    push @dates, $date;
    push @kwalitee, {
      name => sprintf('%s (ver %s)', $date, $version),
      y    => $dist->{kwalitee},
    };
  }

  return {
    xaxis => \@dates,
    series => [
      {name => 'Kwalitee', data => \@kwalitee},
    ],
  };
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Dist::Chart

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
