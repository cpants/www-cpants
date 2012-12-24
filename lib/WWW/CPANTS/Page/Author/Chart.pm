package WWW::CPANTS::Page::Author::Chart;

use strict;
use warnings;
use WWW::CPANTS::DB;

sub load_data {
  my ($class, $id) = @_;

  my $history = db('CPANTS')->fetch_author_history($id);

  my (@dates, @kwalitee, @num_dists);
  for my $run (@$history) {
    push @dates, $run->{date};
    push @kwalitee, {
      name => $run->{date},
      y    => $run->{average_kwalitee},
    };
    push @num_dists, {
      name => $run->{date},
      y    => $run->{num_dists},
    };
  }

  return {
    xaxis  => \@dates,
    series => [
      {name => 'Kwalitee', data => \@kwalitee},
      {name => 'Dists',    data => \@num_dists},
    ],
  };
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Author::Chart

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
