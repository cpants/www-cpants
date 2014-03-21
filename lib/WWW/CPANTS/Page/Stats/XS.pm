package WWW::CPANTS::Page::Stats::XS;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Utils;

sub title { 'XS' }

sub load_data { slurp_json('page/stats_xs') }

sub create_data {
  my $class = shift;

  my $xs_db = db('XS');
  my $stats = $xs_db->fetch_stats;

  for my $row (@$stats) {
    for my $type (qw/latest cpan backpan/) {
      for my $key (qw/xs c cpp ppport_h/) {
        $row->{$type.'_'.$key.'_rate'} = percent($row->{$type.'_'.$key}, $row->{$type.'_total'});
      }
    }
  }

  save_json('page/stats_xs', {stats => $stats});
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Stats::XS

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
