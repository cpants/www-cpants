package WWW::CPANTS::Page::Kwalitee::Indicator;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::JSON;
use WWW::CPANTS::Kwalitee;
use WWW::CPANTS::Utils;

sub load_data {
  my ($class, $name) = @_;

  my $info = metric_info($name) or return;

  my $data = slurp_json('page/kwalitee_indicator');

  my %stats;
  my @years;
  for (@$data) {
    push @years, my $year = $_->{year};
    $stats{$year}{total}{backpan} = $_->{backpan_total} || 0;
    $stats{$year}{total}{cpan} = $_->{cpan_total} || 0;
    $stats{$year}{total}{latest} = $_->{latest_total} || 0;
    $stats{$year}{fail}{backpan} = $_->{"backpan_$name"} || 0;
    $stats{$year}{fail}{cpan}   = $_->{"cpan_$name"} || 0;
    $stats{$year}{fail}{latest} = $_->{"latest_$name"} || 0;
    $stats{$year}{pass} = $stats{$year}{total}{backpan} - $stats{$year}{fail}{backpan};
    for (qw/backpan cpan latest/) {
      $stats{$year}{rate}{$_} = $stats{$year}{total}{$_} ? percent($stats{$year}{fail}{$_}, $stats{$year}{total}{$_}) : '-';
    }
  }

  my $fails = slurp_json("page/kwalitee_fails/$name");

  return {
    info  => $info,
    stats => \%stats,
    fails => $fails,
  };
}

sub create_data {
  my $class = shift;

  my $db = db_r('Kwalitee');
  my $stats = $db->fetch_indicator_stats;

  save_json('page/kwalitee_indicator', $stats);

  for (kwalitee_metrics()) {
    my $name = $_->{name};
    my $dists = $db->fetch_latest_failing_dists($name);
    save_json("page/kwalitee_fails/$name", $dists);
  }
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Kwalitee::Indicator

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 load_data
=head2 create_data

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
