package WWW::CPANTS::Process::Kwalitee::PrereqDist;

use strict;
use warnings;
use WWW::CPANTS::Log;
use WWW::CPANTS::DB;
use WWW::CPANTS::Util::CoreList;
use WWW::CPANTS::Util::Parallel;

sub new {
  my ($class, %args) = @_;
  bless \%args, $class;
}

sub update {
  my $self = shift;

  # As of this writing XS modules are simply ignored
  my $prereq_db = db('PrereqModules');

  $self->log(debug => "updating prereq dist");

  my $prereqs = $prereq_db->fetch_all_prereqs;
  $self->log(debug => 'Processing '.(scalar @$prereqs).' prereqs');

  my $pm = WWW::CPANTS::Util::Parallel->new(
    max_workers => $self->{workers},
  );

  my $ct = 0;
  while (my @p = splice @$prereqs, 0, 1000) {
    $ct += @p;
    $self->log(debug => "processing $ct prereqs");
    $pm->run(sub {
      $self->_update(\@p);
    });
  }
  $pm->wait_all_children;
}

sub _update {
  my ($self, $prereqs) = @_;

  # As of this writing XS modules are simply ignored
  my $prereq_db = db('PrereqModules');
  my $dist_modules_db = db_r('DistModules');
  my $packages_db = db_r('Packages');

  my @strays;
  for my $row (@$prereqs) {
    my ($prereq, $prereq_dist) = @$row{qw/prereq prereq_dist/};
    if ($prereq =~ /(?:\s|\-|[A-Za-z0-9]:[A-Za-z0-9])/) {
      next if defined $prereq_dist && $prereq_dist eq '';
      $self->log(debug => "no dists should have $prereq");
      push @strays, $prereq;
    }
    elsif (my $dist = $packages_db->fetch_dist_by_module($prereq)) {
      next if defined $prereq_dist && $prereq_dist eq $dist->{dist};
      $prereq_db->update_prereq_dist($prereq, $dist->{dist});
    }
    elsif ($prereq eq 'perl' or is_core($prereq)) {
      next if defined $prereq_dist && $prereq_dist eq 'perl';
      $prereq_db->update_prereq_dist($prereq, 'perl');
    }
    else {
      my $dists = $dist_modules_db->fetch_dists_by_modules($prereq);
      if (@$dists) {
        if (@$dists > 1) {
          $self->log(warn => "$prereq is listed in more than one dists (@$dists)");
        }
        next if defined $prereq_dist && $prereq_dist eq $dists->[0];
        $prereq_db->update_prereq_dist($prereq, $dists->[0]);
      }
      else {
        next if defined $prereq_dist && $prereq_dist eq '';
        $self->log(debug => "no dists has $prereq");
        push @strays, $prereq;
      }
    }
  }
  $prereq_db->finalize_update_prereq_dist;
  $prereq_db->update_stray_prereq_dists(\@strays);
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Kwalitee::PrereqDist

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
