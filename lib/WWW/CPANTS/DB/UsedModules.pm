package WWW::CPANTS::DB::UsedModules;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub _columns {(
  [dist => 'text'],
  [distv => 'text', {bulk_key => 1}],
  [module => 'text', {bulk_key => 1}],
  [module_dist => 'text'],
  [in_code => 'integer default 0'],
  [in_tests => 'integer default 0'],
  [in_config => 'integer default 0'],
  [evals_in_code => 'integer default 0'],
  [evals_in_tests => 'integer default 0'],
  [evals_in_config => 'integer default 0'],
)}

sub _indices {(
  ['distv'],
  ['module'],
  ['module_dist'],
  unique => ['distv', 'module'],
)}

# - Process::Kwalitee::PrereqMatchesUse, Page::Dist::Prereq -

sub fetch_used_modules_of {
  my ($self, $distv) = @_;
  $self->fetchall('select module, module_dist, in_code, in_tests, evals_in_code, evals_in_tests from used_modules where distv = ?', $distv);
}

# - Process::Kwalitee::UsedModuleDist -

sub fetch_all_used_modules {
  my $self = shift;
  $self->fetchall('select distinct(module), module_dist from used_modules');
}

sub update_used_module_dist {
  my ($self, $module, $dist) = @_;
  $self->bulk(update_used_module_dist => 'update used_modules set module_dist = ? where module = ?', $dist, $module);
}

sub finalize_update_used_module_dist {
  shift->finalize_bulk('update_used_module_dist');
}

sub update_stray_used_module_dist {
  my ($self, $modules) = @_;
  while (my @m = splice @$modules, 0, 100) {
    my $params = $self->_in_params(\@m);
    $self->do("update used_modules set module_dist = '' where module in ($params)");
  }
}

# - for testing only -

sub fetch_stray_modules {
  my $self = shift;
  $self->fetchall_1('select module from used_modules where module_dist = ""');
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::UsedModules

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 fetch_all_used_modules
=head2 fetch_stray_modules
=head2 fetch_used_modules_of
=head2 update_used_module_dist
=head2 finalize_update_used_module_dist
=head2 update_stray_used_module_dist

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
