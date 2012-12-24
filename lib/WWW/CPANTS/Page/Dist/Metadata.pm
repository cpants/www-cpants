package WWW::CPANTS::Page::Dist::Metadata;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Kwalitee;
use WWW::CPANTS::Utils;
use JSON::XS;

sub load_data {
  my ($class, $name) = @_;

  my $dist = db_r('Kwalitee')->fetch_distv($name);
  return unless $dist && $dist->{analysis_id};

  my $json = db_r('Analysis')->fetch_json_by_id($dist->{analysis_id});
  my $meta = decode_json($json);
  for (keys %$meta) {
    delete $meta->{$_} if /(analysis_id|_kwalitee)$/;
  }
  my %data = (
    dist => $dist,
    meta => $meta,
  );
  return \%data;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Dist::Metadata

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
