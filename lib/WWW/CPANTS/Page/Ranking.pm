package WWW::CPANTS::Page::Ranking;

use strict;
use warnings;
use WWW::CPANTS::JSON;
use Module::Find;
use String::CamelCase qw/decamelize/;

sub title { 'Ranking' }

sub load_data { slurp_json('page/ranking') }

sub create_data {
  my $class = shift;

  my %sort_order = (
    FiveOrMore => 1,
    LessThanFive => 2,
  );

  my @pages;
  for my $package (findallmod 'WWW::CPANTS::Page::Ranking') {
    eval "require $package" or next;
    (my $id = $package) =~ s/^WWW::CPANTS::Page::Ranking:://;
    my $path = $id;
    $path =~ s|::|/|g;
    $path = (length $path < 3) ? lc $path : decamelize($path);
    push @pages, {
      _sort => $sort_order{$id} || 99,
      title => $package->title,
      path => "/ranking/$path",
    };
  }
  save_json('page/ranking', {pages => [sort {$a->{_sort} <=> $b->{_sort}} @pages]});
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Ranking

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 title
=head2 load_data
=head2 create_data

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
