package WWW::CPANTS::Page::Stats::MetaGenerator;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Utils;

sub title { 'META Generator' }

sub load_data { slurp_json('page/stats_meta_generator') }

sub create_data {
  my $class = shift;

  my $db = db_r('DistTools');
  my $stats = $db->fetch_stats;
  my $user_stats = $db->fetch_user_stats;

  save_json('page/stats_meta_generator', { stats => $stats, user_stats => $user_stats });
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Stats::MetaGenerator

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
