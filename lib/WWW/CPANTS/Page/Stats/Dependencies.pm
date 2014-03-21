package WWW::CPANTS::Page::Stats::Dependencies;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Util::JSON;

sub title { 'Dependencies' }

sub load_data { slurp_json('page/stats_dependencies') }

sub create_data {
  my $class = shift;

  my $prereq_db = db_r('PrereqModules');

  my $required_stats = $prereq_db->fetch_stats_of_required;
  my $requires_stats = $prereq_db->fetch_stats_of_requires;
  my $most_required  = $prereq_db->fetch_most_required_dists;
  my $requires_most  = $prereq_db->fetch_dists_that_requires_most;

  save_json('page/stats_dependencies', {
    required_stats => $required_stats,
    requires_stats => $requires_stats,
    most_required => $most_required,
    requires_most => $requires_most,
  });
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Stats::Dependencies

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
