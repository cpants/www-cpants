package WWW::CPANTS::Page::Stats::Uploads;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Utils;

sub title { 'CPAN Uploads' }

sub load_data { slurp_json('page/stats_uploads') }

sub create_data {
  my $class = shift;

  my $uploads_db = db('Uploads');
  $uploads_db->_create_indices;

  my $total = $uploads_db->count_distinct_dists;
  my $cpan_dists = $uploads_db->count_distinct_dists('cpan');
  my $cpan_rate = percent($cpan_dists, $total);
  my $uploads = $uploads_db->count_uploads;

  my $uploads_per_year = $uploads_db->count_uploads_per_year;
  my $most_often_uploaded = $uploads_db->fetch_most_often_uploaded;

  save_json('page/stats_uploads', {
    total => $total,
    cpan_dists => $cpan_dists,
    cpan_rate => $cpan_rate,
    uploads => $uploads,
    uploads_per_year => $uploads_per_year,
    most_often_uploaded => $most_often_uploaded,
  });
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Stats::Uploads

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
