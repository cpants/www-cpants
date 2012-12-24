package WWW::CPANTS::Process::Analysis::PrereqModules;

use strict;
use warnings;
use WWW::CPANTS::DB;

sub new {
  bless { 
    db => db('PrereqModules')->setup,
  }, shift;
}

sub update {
  my ($self, $data) = @_;

  for my $prereq (@{ $data->{prereq} || []}) {
    $self->{db}->bulk_insert({
      dist   => $data->{dist},
      distv  => $data->{vname},
      author => $data->{author},
      prereq => $prereq->{requires},
      prereq_version => $prereq->{version},
      type => (
        $prereq->{is_prereq} ? 1 :
        $prereq->{is_build_prereq} ? 2 :
        3  # optional (recommendations)
      ),
    });
  }
}

sub finalize {
  shift->{db}->finalize_bulk_insert;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Analysis::PrereqModules

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 update
=head2 finalize

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
