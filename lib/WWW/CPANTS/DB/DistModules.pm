package WWW::CPANTS::DB::DistModules;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub dbname { 'dist_modules.db' }
sub schema { return <<'SCHEMA';
create table if not exists dist_modules (
  dist text,
  distv text,
  module text,
  version text,
  released integer
);

create index if not exists dist_idx on dist_modules (dist);

create index if not exists module_idx on dist_modules (module);

create unique index if not exists check_idx on dist_modules (distv, module);
SCHEMA
}

sub bulk_insert {
  my ($self, $bind) = @_;

  my $rows = $self->{_insert_bind} ||= [];
  if (@$rows > 100) {
    $self->bulk('insert or replace into dist_modules (dist, distv, module, version, released) values (?, ?, ?, ?, ?)', $rows);
    @$rows = ();
  }
  push @$rows, [@$bind{qw/dist distv module version released/}];
}

sub finalize_bulk_insert {
  my $self = shift;
  $self->bulk('insert or replace into dist_modules (dist, distv, module, version, released) values (?, ?, ?, ?, ?)', $self->{_insert_bind}) if $self->{_insert_bind};
  delete $self->{_insert_bind};
}

sub dists_by_modules {
  my ($self, $modules) = @_;

  # XXX: need to take dist/module versions into consideration?
  my $params = $self->in_params($modules);
  $self->fetchall_1("select distinct(dist) from (select dist, module from dist_modules where module in ($params) order by released asc) group by module order by dist");
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::DistModules

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
