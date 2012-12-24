package WWW::CPANTS::DB::DistModules;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub _columns {(
  [dist => 'text'],
  [distv => 'text', {bulk_key => 1}],
  [module => 'text', {bulk_key => 1}],
  [version => 'text'],
  [file => 'text'],
  [released => 'integer'],
)}

sub _indices {(
  ['dist'],
  ['module'],
  unique => ['distv', 'module'],
)}

# - Process::Kwalitee::PrereqDist, Process::Kwalitee::UsedModuleDist -

sub fetch_dists_by_modules {
  my ($self, $modules) = @_;

  # XXX: need to take dist/module versions into consideration?
  my $params = $self->_in_params($modules);
  $self->fetchall_1("select distinct(dist) from (select dist, module from dist_modules where module in ($params) order by released asc) group by module order by dist");
}

# - Page::Dist::Provides -

sub fetch_dist_modules {
  my ($self, $distv) = @_;

  $self->fetchall("select * from dist_modules where distv = ?", $distv);
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::DistModules

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 fetch_dists_by_modules
=head2 fetch_dist_modules

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
