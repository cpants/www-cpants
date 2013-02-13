package WWW::CPANTS::Page::Author::Feed;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Utils;
use Time::Piece;
use XML::Atom::SimpleFeed;

sub load_data {
  my ($class, $id, $base) = @_;
  my $uid = uc $id;

  my $rows = db('Kwalitee')->fetch_author_history($uid);

  my $link = "$base/author/$uid/feed";
  my $feed = XML::Atom::SimpleFeed->new(
    title => "CPANTS Feed for $uid",
    author => 'CPANTS',
    updated => gmtime(@$rows ? $rows->[0]{released} : time)->datetime.'Z',
    id => $link,
    link => $link,
  );
  for my $row (@$rows) {
    $feed->add_entry(
      title => $row->{distv},
      link => "$base/dist/$row->{distv}",
      id => $row->{distv},
      summary => "Kwalitee: ".decimal($row->{kwalitee}),
      updated => gmtime($row->{released})->datetime.'Z',
    );
  }
  $feed->as_string;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Author::Feed

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
