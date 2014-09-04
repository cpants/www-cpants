package WWW::CPANTS::Page::Dist::Overview;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Analyze::Metrics;

sub load_data {
  my ($class, $name) = @_;

  my $dist = db_r('Kwalitee')->fetch_distv($name) or return;
  ($dist->{version} = $dist->{distv}) =~ s/^$dist->{dist}\-//;

  my $recent = db_r('Uploads')->fetch_recent_versions($dist->{dist}, 11);

  my $kwalitee = [sorted_metrics($dist, requires_remedy => 1)];

  my $urls = db_r('MetaYML')->fetch_urls($dist->{analysis_id});

  return {
    dist => $dist,
    recent => $recent,
    kwalitee => $kwalitee,
    resource_urls => $urls,
  };
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Dist::Overview

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
