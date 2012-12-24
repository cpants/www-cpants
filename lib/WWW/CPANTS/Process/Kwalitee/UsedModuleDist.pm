package WWW::CPANTS::Process::Kwalitee::UsedModuleDist;

use strict;
use warnings;
use WWW::CPANTS::Log;
use WWW::CPANTS::DB;
use WWW::CPANTS::CoreList;
use WWW::CPANTS::Parallel;

sub new {
  my ($class, %args) = @_;
  bless \%args, $class;
}

sub update {
  my $self = shift;

  $self->log(debug => "updating used module dist");

  my $used_db = db('UsedModules');

  my $modules = $used_db->fetch_all_used_modules;
  $self->log(debug => 'Processing '.(scalar @$modules).' modules');

  my $pm = WWW::CPANTS::Parallel->new(
    max_workers => $self->{workers},
  );

  my $ct = 0;
  while (my @m = splice @$modules, 0, 1000) {
    $ct += @m;
    $self->log(debug => "processing $ct modules");
    $pm->run(sub {
      $self->_update(\@m);
    });
  }
  $pm->wait_all_children;
}

sub _update {
  my ($self, $modules) = @_;

  my $used_db = db('UsedModules');
  my $dist_modules_db = db_r('DistModules');
  my $packages_db = db_r('Packages');

  my @strays;
  for my $row (@$modules) {
    my ($module, $module_dist) = @$row{qw/module module_dist/};
    if ($module =~ /(?:\s|\-|[A-Za-z0-9]:[A-Za-z0-9])/) {
      next if defined $module_dist && $module_dist eq '';
      $self->log(debug => "no dists should have $module");
      push @strays, $module;
    }
    elsif (my $dist = $packages_db->fetch_dist_by_module($module)) {
      next if defined $module_dist && $module_dist eq $dist->{dist};
      $used_db->update_used_module_dist($module, $dist->{dist});
    }
    elsif ($module eq 'perl' or is_core($module)) {
      next if defined $module_dist && $module_dist eq 'perl';
      $used_db->update_used_module_dist($module, 'perl');
    }
    else {
      my $dists = $dist_modules_db->fetch_dists_by_modules($module);
      if (@$dists) {
        if (@$dists > 1) {
          $self->log(warn => "$module is listed in more than one dists (@$dists)");
        }
        next if defined $module_dist && $module_dist eq $dists->[0];
        $used_db->update_used_module_dist($module, $dists->[0]);
      }
      else {
        next if defined $module_dist && $module_dist eq '';
        $self->log(debug => "no dists has $module");
        push @strays, $module;
      }
    }
  }
  $used_db->finalize_update_used_module_dist;
  $used_db->update_stray_used_module_dist(\@strays);
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Kwalitee::UsedModuleDist

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 update

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
