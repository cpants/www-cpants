package WWW::CPANTS::Analyze;

use strict;
use warnings;
use WWW::CPANTS::Extlib;
use WWW::CPANTS::Analyze::Context;
use WWW::CPANTS::Log;
use Module::CPANTS::Kwalitee;

sub new {
  my ($class, %args) = @_;

  $args{kwalitee} = Module::CPANTS::Kwalitee->new;

  bless \%args, $class;
}

sub analyze {
  my ($self, %args) = @_;

  for (qw/no_capture timeout/) {
    $args{$_} = $self->{$_} unless defined $args{$_};
  }

  my $context = WWW::CPANTS::Analyze::Context->new(%args) or return;

  if ($context->extract) {
    my %elapsed;
    eval {
      local $SIG{ALRM} = sub { die "timeout\n" };
      alarm($args{timeout} || 0);

      for my $module (@{ $self->{kwalitee}->generators }) {
        my $started = time;
        my @warnings;
        eval {
          local $SIG{__WARN__} = sub { push @warnings, @_ };
          $module->analyse($context)
        };
        $elapsed{$module} = time - $started;
        if (@warnings) {
          $context->set_error(cpants_warnings => "$args{dist}: ".join '', @warnings);
        }
        if (my $error = $@) {
          if ($error eq "timeout\n") {
            die $error;
          }
          else {
            $context->set_error($module => $error);
            $self->log(error => "$args{dist}: $error");
          }
        }
      }
      alarm 0;
    };
    if (my $error = $@) {
      $context->stop_capturing; # not to swallow warnings
      $self->log(warn => "$args{dist}: $error");

      if ($error eq "timeout\n") {
        $context->set_error(timeout => 1);
        my $elapsed_str =
          join ',',
          map  {"$_: $elapsed{$_}"}
          sort {$elapsed{$b} <=> $elapsed{$a}}
          grep {$elapsed{$_}}
          keys %elapsed;
        $self->log(error => "$args{dist}: timeout ($elapsed_str)");
      }
      else {
        $self->log(error => "$args{dist}: $error");
        $context->set_error(cpants => $error);
      }

      return;
    }
  }
  else {
    # distname info can be taken even when the extraction fails
    my @modules = qw/
      Module::CPANTS::Kwalitee::Distname
    /;
    for my $module (@modules) {
      eval { $module->analyse($context); };
      if (my $error = $@) {
        $context->set_error($module => $error);
        $self->log(error => "$args{dist}: $error");
      }
    }
    # for statistics
    $context->d->{released_epoch} = (stat($context->dist))[9];
  }

  # remove redundant information that can be easily generated.
  delete $context->stash->{$_} for qw/
    dirs_list files_list ignored_files_list
  /;

  # make sure the dist has some perl stuff
  $self->check_perl_stuff($context) or return $context;

  $self->calc_kwalitee($context);
}

sub check_perl_stuff {
  my ($self, $context) = @_;

  for (@{ $context->stash->{files_array} || []}) {
    return 1 if /\.(?:pm|PL)$/;
    return 1 if /\bMETA\.(?:yml|json)$/;
  }
  $context->stash->{has_no_perl_stuff} = 1;

  return;
}

sub calc_kwalitee {
  my ($self, $context) = @_;

  $context->set(kwalitee => {});
  my $kwalitee = 0;
  my $total_kwalitee = 0;
  for my $module (@{ $self->{kwalitee}->generators }) {
    for my $indicator (@{ $module->kwalitee_indicators }) {
      next if $indicator->{needs_db};
      next if $indicator->{is_disabled};
      my $ret = $indicator->{code}($context->stash, $indicator);
      $ret = $ret > 0 ? 1 : 0;  # normalize
      $context->set_kwalitee($indicator->{name} => $ret);
      next if $indicator->{is_experimental};
      $kwalitee += $ret;
      $total_kwalitee++;
    }
  }

  # this value is tentative and will be finalized later,
  # but anyway this should always look like an actual kwalitee score,
  # even when the process happens to fail.
  $context->set_kwalitee(kwalitee => sprintf("%.2f", $kwalitee / $total_kwalitee * 100));

  $context;
}

# not to break things; should not use this anyway

unless (main->can('logger')) {
  *main::logger = sub {};
}

1;

__END__

=head1 NAME

WWW::CPANTS::Analyze

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 check_perl_stuff
=head2 analyze
=head2 calc_kwalitee

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
