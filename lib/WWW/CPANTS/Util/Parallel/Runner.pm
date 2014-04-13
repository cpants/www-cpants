package WWW::CPANTS::Util::Parallel::Runner;

use strict;
use warnings;
use WWW::CPANTS::Extlib;
use WWW::CPANTS::Log;
use Parallel::Runner;

sub new {
  my ($class, %args) = @_;

  $args{max_workers} = 0 if $INC{'Devel/Cover.pm'};

  my $self = bless \%args, $class;
  $self->{_caller} = caller;

  if ($args{max_workers}) {
    my $runner = Parallel::Runner->new($args{max_workers});
    if ($self->{debug}) {
      $runner->reap_callback(sub {
        my ($exit, $pid) = @_;
        print "finished (pid: $pid, exit: $exit)\n";
      });
    }
    $self->{_obj} = $runner;
    for my $sig (qw/TERM INT/) {
      $SIG{$sig} = sub {
        warn localtime." $$: Terminating on $sig\n";
        if ($runner->pid eq $$) {
          warn localtime." $$: signalling workers\n";
          $runner->killall($sig);
          $runner->finish;
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
  $self->{_obj}->finish;
}

sub run {
  my ($self, $code) = @_;

  if ($self->{_obj}) {
    $self->{_obj}->run(sub {
      $0 = "cpants worker ($self->{_caller})";
      $code->();
    });
  }
  else {
    eval { $code->() };
    $self->log(error => $@) if $@;
  }
}

1;

__END__

=head1 NAME

WWW::CPANTS::Util::Parallel::Runner

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
