package WWW::CPANTS::Util::Parallel::ForkManager;

use strict;
use warnings;
use WWW::CPANTS::Extlib;
use WWW::CPANTS::Log;
use Parallel::ForkManager;
use Scope::OnExit;

sub new {
  my ($class, %args) = @_;

  $args{max_workers} = 0 if $INC{'Devel/Cover.pm'};

  my $self = bless \%args, $class;
  $self->{_caller} = caller;

  if ($args{max_workers}) {
    my $manager = Parallel::ForkManager->new($args{max_workers});
    if ($args{debug}) {
      $manager->run_on_finish(sub {
        my ($pid, $exit, $id, $signal, $dump) = @_;
        $class->log(debug => "finished (pid: $pid, exit: $exit)");
      });
    }
    $self->{_obj} = $manager;

    # XXX: not sure why but this doesn't work properly on Windows...
    for my $sig (qw/TERM INT/) {
      $SIG{$sig} = sub {
        warn localtime." $$: Terminating on $sig\n";
        if (!$manager->{in_child}) {
          warn localtime." $$: signalling workers\n";
          kill $sig, $_ for keys %{ $manager->{processes} };
        }
        exit;
      };
    }
  }
  $self;
}

sub wait_all_children {
  my $self = shift;
  return unless $self->{_obj};
  $self->{_obj}->wait_all_children;
}

sub run {
  my ($self, $code) = @_;

  if ($self->{_obj}) {
    $self->{_obj}->start and return;
    on_scope_exit { $self->{_obj}->finish };
    $0 = "cpants worker (" . $self->{_caller} . ")";
    eval { $code->() };
    $self->log(error => $@) if $@;
    exit;
  }
  else {
    eval { $code->() };
    $self->log(error => $@) if $@;
  }
}

1;

__END__

=head1 NAME

WWW::CPANTS::Util::Parallel::ForkManager

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 wait_all_children
=head2 run

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
