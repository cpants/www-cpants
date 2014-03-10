package WWW::CPANTS::Page::Author::Fails;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Kwalitee;
use WWW::CPANTS::Utils;

sub load_data {
  my ($class, $id) = @_;

  my $author_info = db('Authors')->fetch_author($id) or return;
  my $dists = db('Kwalitee')->fetch_author_kwalitee($id) or return;

  my @metrics;
  for my $metric (sort {$a->{key} cmp $b->{key}} @{scalar sorted_metrics({})}) {
    my $name = $metric->{key};
    my @fails;
    for my $dist (@$dists) {
      push @fails, $dist->{distv} unless $dist->{$name};
    }
    push @metrics, {name => $name, fails => \@fails} if @fails;
  }

  { metrics => \@metrics };
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Author::Fails

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
