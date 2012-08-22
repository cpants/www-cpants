package WWW::CPANTS::Process::Authors;

use strict;
use warnings;
use WWW::CPANTS::DB::Authors;
use WWW::CPANTS::Log;
use WorePAN;

sub new {
  my ($class, %args) = @_;

  WWW::CPANTS::DB::Authors->new->setup;

  bless \%args, $class;
}

sub update_authors {
  my ($self, %args) = @_;

  my $cpan = $args{cpan} || $self->{cpan} or die "requires cpan";
  my $worepan = WorePAN->new(root => $cpan);
  my $db = WWW::CPANTS::DB::Authors->new;

  my $ct = 0;
  for (@{ $worepan->authors || [] }) {
    $db->bulk_insert($_);
    $self->log(debug => "updated $ct authors") unless ++$ct % 1000;
  }
  $db->finalize_bulk_insert;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Authors

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
