package WWW::CPANTS::Page::Recent;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Utils;
use Time::Piece;
use Time::Seconds;

sub title { 'Recent Uploads' }

sub load_data { slurp_json('page/recent') }

sub create_data {
  my $class = shift;

  my $since = (Time::Piece->new - ONE_DAY * 7)->epoch;

  my $uploads = db_r('Uploads')->fetch_recent_uploads($since);
  return [] unless @$uploads;

  my $date = $uploads->[0]{date};
  my @recent;
  my @items;
  for my $upload (@$uploads) {
    if ($date ne $upload->{date}) {
      push @recent, _fix_items($date, \@items);

      $date = $upload->{date};
      @items = ();
    }
    push @items, $upload;
  }
  push @recent, _fix_items($date, \@items) if @items;

  save_json('page/recent', {recent => \@recent});
}

sub _fix_items {
  my ($date, $items) = @_;

  my @dists = map {$_->{distv}} @$items;
  my $rows = db_r('Kwalitee')->fetch_distv_kwalitee(\@dists);
  my %map = map {$_->{distv} => $_->{kwalitee}} @$rows;
  for my $item (@$items) {
    $item->{kwalitee} = $map{$item->{distv}};
  }

  return {items => [@$items], date => $date};
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Recent

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 title
=head2 load_data
=head2 create_data

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
