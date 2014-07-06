package WWW::CPANTS::Process::Analysis::ModuleInstall;

use strict;
use warnings;
use WWW::CPANTS::DB;

sub new {
  bless {
    db => db('ModuleInstall')->setup,
  }, shift;
}

sub update {
  my ($self, $data) = @_;

  return unless $data->{module_install}{version};

  $self->{db}->bulk_insert({
    analysis_id => $data->{id},
    version => $data->{module_install}{version},
    dist_released => $data->{released_epoch},
  });
}

sub finalize {
  shift->{db}->finalize_bulk_insert;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Analysis::ModuleInstall

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
