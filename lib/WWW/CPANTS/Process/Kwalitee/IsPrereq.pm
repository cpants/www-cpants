package WWW::CPANTS::Process::Kwalitee::IsPrereq;

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

  $self->log(debug => "updating is_prereq");

  my $prereq_db = db('PrereqModules');
  my $kwalitee_db = db('Kwalitee');

  my $ct = 0;
  while(my $row = $kwalitee_db->iterate(qw/author dist analysis_id is_prereq/)) {
    my $count = $prereq_db->fetch_first_dependent_by_others($row->{dist}, $row->{author});
    my $is_prereq = $count ? 1 : 0;
    if (!defined $row->{is_prereq} or $row->{is_prereq} ne $is_prereq) {
      $kwalitee_db->update_is_prereq($row->{analysis_id}, $is_prereq);
    }
    $self->log(debug => "updated $ct is_prereq") unless ++$ct % 1000;
  }
  $kwalitee_db->finalize_update_is_prereq;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Kwalitee::IsPrereq

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
