package WWW::CPANTS::Page::Kwalitee::Chart::Indicator;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Analyze::Metrics;

sub load_data {
  my ($class, $name) = @_;

  my $info = metric_info($name) or return;

  my $data = slurp_json('page/kwalitee_indicator');

  my @years;
  my (%fail, %pass);
  for (@$data) {
    push @years, my $year = $_->{year};
    $fail{backpan}{$year} = $_->{"backpan_$name"} || 0;
    $fail{cpan}{$year}    = $_->{"cpan_$name"} || 0;
    $fail{latest}{$year}  = $_->{"latest_$name"} || 0;
    $pass{$year} = $_->{backpan_total} - $fail{backpan}{$year};
  }

  return {
    xaxis => \@years,
    series => [
      {name => 'PASS' => data => [@pass{@years}]},
      {name => 'FAIL (backpan)' => data => [@{$fail{backpan}}{@years}]},
      {name => 'FAIL (cpan)'    => data => [@{$fail{cpan}}{@years}]},
      {name => 'FAIL (latest)'  => data => [@{$fail{latest}}{@years}]},
    ]
  };
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Kwalitee::Chart::Indicator

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
