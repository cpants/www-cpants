package WWW::CPANTS::Page::API::Kwalitee;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Kwalitee;
use WWW::CPANTS::Utils;

sub load_data {
  my ($class, $id) = @_;

  my $author = db('Authors')->fetch_author($id) or return;
  my $dists = db('Kwalitee')->fetch_author_kwalitee($id) or return;

  my $info = {
    Average_Kwalitee => decimal($author->{average_kwalitee}),
    CPANTS_Game_Kwalitee => decimal($author->{average_core_kwalitee}),
    Email => $author->{email},
    Liga => $author->{liga} ? '5 or more' : 'less than 5',
    Rank => $author->{rank},
  };

  my %distributions;
  for my $dist (@$dists) {
    my $name = $dist->{dist};
    my $kwalitee = decimal($dist->{kwalitee});
    my %details;
    for (kwalitee_metrics()) {
      $details{$_->{name}} = $dist->{$_->{name}} ? 'ok' : 'opt_not_ok';
    }
    $distributions{$name} = {
      kwalitee => $kwalitee,
      details => \%details,
    };
  }

  my %data = (
    info => $info,
    distributions => \%distributions,
  );

  \%data;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::API::Kwalitee

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
