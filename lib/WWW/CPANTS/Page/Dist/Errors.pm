package WWW::CPANTS::Page::Dist::Errors;

use strict;
use warnings;
use WWW::CPANTS::DB;

sub load_data {
  my ($class, $name) = @_;

  my $dist = db_r('Kwalitee')->fetch_distv($name);
  return unless $dist && $dist->{distv};

  my $errors = db_r('Errors')->fetch_distv_errors($dist->{analysis_id});
  $errors = [grep {$_->{category} ne 'cpants_warnings'} @$errors];

  my %data = (
    dist => $dist,
    errors => $errors,
  );
  return \%data;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Dist::Errors

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
