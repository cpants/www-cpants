package WWW::CPANTS::DB::Packages;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub _columns {(
  [module => 'text primary key not null', {bulk_key => 1}],
  [version => 'text'],
  [file => 'text'],
  [dist => 'text'],
  [distv => 'text'],
  [author => 'text'],
  [status => 'integer default 0'],
)}

sub _indices {(
  ['dist'],
  ['author'],
)}

# - Process::Kwalitee::PrereqDist, Process::Kwalitee::UsedModuleDist -

sub fetch_dist_by_module {
  my ($self, $module) = @_;
  $self->fetch("select * from packages where module = ?", $module);
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::Packages

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 fetch_dist_by_module

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
