package WWW::CPANTS::Process::Analysis::DistModules;

use strict;
use warnings;
use WWW::CPANTS::DB;

sub new {
  bless {
    db => db('DistModules')->setup,
  }, shift;
}

sub update {
  my ($self, $data) = @_;

  # As of this writing XS modules are ignored
  for my $module (@{ $data->{modules} || []}) {
    $self->{db}->bulk_insert({
      dist     => $data->{dist},
      distv    => $data->{vname},
      module   => $module->{module},
      file     => $module->{file},
      released => $data->{released_epoch},

      # TODO: get something from CPAN::ParseDistribution
      # to improve $data->{versions}{$module->file}
      version  => 0,
    });
  }
}

sub finalize {
  shift->{db}->finalize_bulk_insert;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Analysis::DistModules

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
