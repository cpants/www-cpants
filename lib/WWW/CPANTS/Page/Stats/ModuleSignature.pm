package WWW::CPANTS::Page::Stats::ModuleSignature;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::JSON;
use WWW::CPANTS::Utils;

sub load_data { slurp_json('page/stats_module_signature') }

sub create_data {
  my $class = shift;

  my $results = db_r('ModuleSignature')->fetch_result_stats;
  my %total;
  for my $result (@$results) {
    for (qw/latest cpan backpan/) {
      $total{$_} += $result->{$_};
    }
  }
  for my $result (@$results) {
    for (qw/latest cpan backpan/) {
      $result->{$_.'_rate'} = percent($result->{$_}, $total{$_});
    }
  }

  save_json('page/stats_module_signature', {
    results => $results,
  });
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Stats::ModuleSignature

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
