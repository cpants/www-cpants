package WWW::CPANTS::ForkManager;

use strict;
use warnings;
use WWW::CPANTS::Extlib;

sub new {
  my $class = shift;

  return if $INC{'Devel/Cover.pm'};

#  my $manager = $class->_prefork(@_) || $class->_forkmanager(@_)
  my $manager = $class->_forkmanager(@_)
    or die "requires Parallel::Prefork or Parallel::ForkManager\n";

  bless {manager => $manager}, $class;
}

sub _prefork {
  my ($class, %args) = @_;
  eval { require Parallel::Prefork } or return;

  Parallel::Prefork->new(\%args);
}

sub _forkmanager {
  my ($class, %args) = @_;
  eval { require Parallel::ForkManager } or do { warn $@; return;};

  my $manager = Parallel::ForkManager->new($args{max_workers});
  if ($args{on_child_reap}) {
    $manager->run_on_finish($args{on_child_reap});
  }

  $manager;
}

sub start  { shift->{manager}->start }
sub finish { shift->{manager}->finish }
sub wait_all_children { shift->{manager}->wait_all_children }

1;

__END__

=head1 NAME

WWW::CPANTS::ForkManager

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
