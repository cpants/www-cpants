package WWW::CPANTS::Page::Stats::DistSize;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::JSON;
use WWW::CPANTS::Utils;
use List::Util qw/sum/;

sub title { 'Distribution Size' }

sub load_data { slurp_json('page/stats_dist_size') }

sub create_data {
  my $class = shift;

  my $db = db_r('DistSize');
  my $packed   = $db->fetch_packed_size_stats;
  my $unpacked = $db->fetch_unpacked_size_stats;
  my $largest  = $db->fetch_largest_dists;

  my %tmp;
  my $total = sum map {$_->{count}} @$packed;
  for (@$packed) {
    my $cat = $_->{cat};
    $tmp{$cat}{packed} = $_->{count};
    $tmp{$cat}{sort}   = $_->{sort};
    $tmp{$cat}{cat}    = $_->{cat};
    $tmp{$cat}{packed_rate} = percent($_->{count}, $total);
  }
  for (@$unpacked) {
    my $cat = $_->{cat};
    $tmp{$cat}{unpacked} = $_->{count};
    $tmp{$cat}{sort}     = $_->{sort};
    $tmp{$cat}{cat}      = $_->{cat};
    $tmp{$cat}{unpacked_rate} = percent($_->{count}, $total);
  }
  my $merged = [
    map  { $tmp{$_} }
    sort { $tmp{$b}{sort} <=> $tmp{$a}{sort} }
    keys %tmp
  ];

  save_json('page/stats_dist_size', {
    merged   => $merged,
    packed   => $packed,
    unpacked => $unpacked,
    total    => $total,
    largest  => $largest,
  });
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Stats::DistSize

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 title
=head2 create_data
=head2 load_data

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
