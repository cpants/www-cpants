package WWW::CPANTS::Process::Kwalitee::DistDependents;

use strict;
use warnings;
use WWW::CPANTS::Log;
use WWW::CPANTS::DB;
use WWW::CPANTS::Util::Parallel;

sub new {
  my ($class, %args) = @_;
  bless \%args, $class;
}

sub update {
  my $self = shift;

  my $deps_db = db('DistDependents')->setup;
  my $prereq_db = db_r('PrereqModules');

  $self->log(debug => "updating dist dependents");

  my $dists = $prereq_db->fetch_all_prereq_dists;
  $self->log(debug => 'Processing '.(scalar @$dists).' dists');

  my $pm = WWW::CPANTS::Util::Parallel->new(
    max_workers => $self->{workers},
  );

  $deps_db->mark;
  my $ct = 0;
  while (my @d = splice @$dists, 0, 1000) {
    $ct += @d;
    $self->log(debug => "processing $ct dists");
    $pm->run(sub {
      $self->_update(\@d);
    });
  }
  $pm->wait_all_children;
  $deps_db->unmark;
}

sub _update {
  my ($self, $dists) = @_;

  my $deps_db = db('DistDependents');
  my $prereq_db = db_r('PrereqModules');

  for (@$dists) {
    my $deps = $prereq_db->fetch_dependents($_);
    $deps_db->bulk_insert({
      dist => $_,
      dependents => join(',', @$deps),
    });
  }
  $deps_db->finalize_bulk_insert;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Kwalitee::DistDependents

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
