package WWW::CPANTS::Page::Dist::UsedBy;

use strict;
use warnings;
use WWW::CPANTS::DB;

sub load_data {
  my ($class, $name, $page) = @_;

  $page ||= 1;
  my $per_page = 1000;
  my $start = ($page - 1) * $per_page + 1;
  my $end = $page * $per_page;

  my $kwalitee_db = db('Kwalitee');
  my $dist = $kwalitee_db->fetch_distv($name);
  return unless $dist && $dist->{distv};

  my $dependents = db('DistDependents')->fetch_dependents($dist->{dist});
  my $total = @$dependents;
  my ($deps, $prev, $next);
  if ($start > $total) {
    # nothing
  } else {
    my @slice = @$dependents[$start - 1 .. ($end > $total ? $total : $end) - 1];
    $deps = $kwalitee_db->fetch_latest_dists(@slice);
    $prev = $page > 1 ? $page - 1 : 0;
    $next = $total > $end ? $page + 1 : 0;
  }

  my %data = (
    dist => $dist,
    deps => $deps,
    prev => $prev,
    next => $next,
    total => $total,
    page => $page,
    pages => int(($total - 1) / $per_page) + 1,
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
