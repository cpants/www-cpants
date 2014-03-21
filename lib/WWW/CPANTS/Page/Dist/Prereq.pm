package WWW::CPANTS::Page::Dist::Prereq;

use strict;
use warnings;
use WWW::CPANTS::DB;
use List::MoreUtils qw/uniq/;

sub load_data {
  my ($class, $name) = @_;

  my $dist = db('Kwalitee')->fetch_distv($name);
  return unless $dist && $dist->{distv};

  my $all_prereqs = db('PrereqModules')->fetch_prereqs_of($dist->{distv});
  my $all_uses = db('UsedModules')->fetch_used_modules_of($dist->{distv});

  my $dists = db('Kwalitee')->fetch_latest_dists(
    uniq
      (map { $_->{prereq_dist} } @$all_prereqs),
      (map { $_->{module_dist} } @$all_uses),
  );
  my %dist_map = map { $_->{dist} => $_ } @$dists;
  $dist_map{perl} = {distv => 'perl', dist => 'perl'};

  my (@prereqs, @build_prereqs, @optional_prereqs);
  for (@$all_prereqs) {
    $_->{dist} = $dist_map{$_->{prereq_dist}} || {};
    my $type = $_->{type} || 1;
    push @prereqs, $_          if $type == 1;
    push @build_prereqs, $_    if $type == 2;
    push @optional_prereqs, $_ if $type == 3;
  }

  my (@used_in_code, @used_in_tests);
  for (@$all_uses) {
    $_->{dist} = $dist_map{$_->{module_dist}} || {};
    push @used_in_code, $_  if $_->{in_code};
    push @used_in_tests, $_ if $_->{in_tests};
  }

  my %data = (
    dist => $dist,
    prereqs => \@prereqs,
    build_prereqs => \@build_prereqs,
    optional_prereqs => \@optional_prereqs,
    used_in_code => \@used_in_code,
    used_in_tests => \@used_in_tests,
  );
  return \%data;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Dist::Prereq

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
