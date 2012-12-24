package WWW::CPANTS::Page::Stats::Authors;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::JSON;
use WWW::CPANTS::Utils;

sub load_data { slurp_json('page/stats_authors') }

sub create_data {
  my $class = shift;

  my $authors_db = db_r('Authors');
  my $total = $authors_db->count_authors;
  my $contributed = $authors_db->count_contributed_authors;
  my $contribution_rate = percent($contributed, $total);
  my $most_contributed_authors = $authors_db->fetch_most_contributed_authors;

  my $uploads_db = db_r('Uploads');
  my $active_authors_per_year = $uploads_db->count_active_authors_per_year;

  save_json('page/stats_authors', {
    total => $total,
    contributed => $contributed,
    contribution_rate => $contribution_rate,
    active_authors_per_year => $active_authors_per_year,
    most_contributed_authors => $most_contributed_authors,
  });
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Stats::Authors

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
