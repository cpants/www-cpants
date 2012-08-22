package WWW::CPANTS::Kwalitee;

use strict;
use warnings;
use List::Util qw/first/;
use WWW::CPANTS::JSON;
use WWW::CPANTS::Extlib;
use Sub::Install qw/reinstall_sub/;

my $METRICS;
my %MAPPING;

our @EXPORT = qw/
  metrics_file kwalitee_metrics sorted_metrics
  is_valid_metric load_metrics save_metrics
/;

sub import {
  my $class = shift;
  my $caller = caller;

  load_metrics();

  for (@EXPORT) {
    reinstall_sub({code => $_, into => $caller});
  }
}

sub metrics_file { json_file('kwalitee_metrics') }
sub kwalitee_metrics { @{ $METRICS || []} }
sub load_metrics {
  $METRICS = slurp_json('kwalitee_metrics');
  %MAPPING = map {($_->{name} => 1)} @{$METRICS || []};
  $METRICS;
}

sub save_metrics {
  require Module::CPANTS::Kwalitee;
  my $kwalitee = Module::CPANTS::Kwalitee->new;
  my @indicators = map {
    my $i = $_;
    +{
      map { $_ => $i->{$_} }
      qw/name error remedy is_extra is_experimental/
    }
  } $kwalitee->get_indicators;
  $METRICS = \@indicators;
  save_json('kwalitee_metrics', \@indicators);
}

sub is_valid_metric {
  my $metric = shift;
  $MAPPING{$metric} ? 1 : 0;
}

sub sorted_metrics {
  my ($kwalitee, %opts) = @_;

  my %categories;
  for my $metric (@{$METRICS || []}) {
    my $type = 
      $metric->{is_extra}        ? 'extra' :
      $metric->{is_experimental} ? 'experimental' :
      'core';

    my $value = $kwalitee->{$metric->{name}};
    (my $name = $metric->{name}) =~ tr/_/ /;
    my $entry = {
      key             => $metric->{name},
      name            => $name,
      value           => $value,
      is_extra        => $metric->{is_extra},
      is_experimental => $metric->{is_experimental},
    };
    if (!$value && $opts{requires_remedy}) {
      $entry->{error}  = $metric->{error};
      $entry->{remedy} = $metric->{remedy};
    }

    push @{$categories{$type} ||= []}, $entry;
  }
  wantarray
    ? ($categories{core}, $categories{extra})
    : [@{$categories{core}}, @{$categories{extra}}];
}

1;

__END__

=head1 NAME

WWW::CPANTS::Kwalitee

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 metrics_file
=head2 load_metrics
=head2 save_metrics
=head2 is_valid_metric
=head2 kwalitee_metrics
=head2 sorted_metrics

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
