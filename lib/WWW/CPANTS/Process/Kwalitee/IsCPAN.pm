package WWW::CPANTS::Process::Kwalitee::IsCPAN;

use strict;
use warnings;
use WWW::CPANTS::Log;
use WWW::CPANTS::DB;

sub new {
  my ($class, %args) = @_;
  bless \%args, $class;
}

sub update {
  my $self = shift;

  $self->_update_is_cpan;
  $self->_update_is_latest;
}

sub _update_is_cpan {
  my $self = shift;

  $self->log(debug => "updating is_cpan");

  my $uploads_db = db_r('Uploads');
  my $cpan_dists = $uploads_db->cpan_dists;

  my $kwalitee_db = db('Kwalitee');

  $kwalitee_db->mark_current_cpan;
  $kwalitee_db->mark_cpan($cpan_dists);
  $kwalitee_db->unmark_previous_cpan;
}

sub _update_is_latest {
  my $self = shift;

  $self->log(debug => "updating is_latest");

  my $uploads_db = db_r('Uploads');
  my $latest_dists = $uploads_db->latest_stable_dists;

  my $kwalitee_db = db('Kwalitee');

  $kwalitee_db->mark_current_latest;
  $kwalitee_db->mark_latest($latest_dists);
  $kwalitee_db->mark_implicit_latest;
  $kwalitee_db->unmark_previous_latest;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Kwalitee::IsCPAN

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
