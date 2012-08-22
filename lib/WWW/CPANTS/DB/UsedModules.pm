package WWW::CPANTS::DB::UsedModules;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub dbname { 'used.db' }
sub schema { return <<'SCHEMA';
create table if not exists used_modules (
  distv text,
  module text,
  module_dist text,
  in_code integer default 0,
  in_tests integer default 0
);

create index if not exists distv_idx on used_modules (distv);

create index if not exists module_idx on used_modules (module);

create unique index if not exists check_idx on used_modules (distv, module);
SCHEMA
}

sub bulk_insert {
  my ($self, $bind) = @_;

  my $rows = $self->{_insert_bind} ||= [];
  if (@$rows > 100) {
    $self->bulk('insert or replace into used_modules (distv, module, in_code, in_tests) values (?, ?, ?, ?)', $rows);
    @$rows = ();
  }
  push @$rows, [@$bind{qw/distv module in_code in_tests/}];
}

sub finalize_bulk_insert {
  my $self = shift;
  $self->bulk('insert or replace into used_modules (distv, module, in_code, in_tests) values (?, ?, ?, ?)', $self->{_insert_bind}) if $self->{_insert_bind};
  delete $self->{_insert_bind};
}

sub fetch_all_used_modules {
  my $self = shift;
  $self->fetchall_1('select distinct(module) from used_modules');
}

sub update_used_module_dist {
  my ($self, $module, $dist) = @_;
  $self->do('update used_modules set module_dist = ? where module = ?', $dist, $module);
}

sub fetch_used_modules_of {
  my ($self, $distv) = @_;
  $self->fetchall('select module, module_dist, in_code, in_tests from used_modules where distv = ?', $distv);
}

sub fetch_orphan_modules {
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

=head2 new

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
