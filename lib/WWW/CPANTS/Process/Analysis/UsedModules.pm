package WWW::CPANTS::Process::Analysis::UsedModules;

use strict;
use warnings;
use WWW::CPANTS::DB;

sub new {
  bless { 
    db => db('UsedModules')->setup,
  }, shift;
}

sub update {
  my ($self, $data) = @_;

  my $uses = $data->{uses} || {};
  my %modules;
  for my $key (keys %$uses) {
    for my $mod (keys %{$uses->{$key}}) {
      $modules{$mod}{$key} += $uses->{$key}{$mod};
    }
  }

  for my $module (keys %modules) {
    next if !$module; # ignore evaled stuff
    next if $module =~ /^v?5/; # ignore perl
    next if $module =~ /[^A-Za-z0-9_:]/; # not a valid package

    $self->{db}->bulk_insert({
      dist     => $data->{dist},
      distv    => $data->{vname},
      module   => $module,
      (map {$_ => $modules{$module}{$_}} qw/
        used_in_code used_in_tests used_in_config
        used_in_eval_in_code used_in_eval_in_tests used_in_eval_in_config
        required_in_code required_in_tests required_in_config
        required_in_eval_in_code required_in_eval_in_tests required_in_eval_in_config
        noed_in_code noed_in_tests noed_in_config
        noed_in_eval_in_code noed_in_eval_in_tests noed_in_eval_in_config
      /),
    });
  }
}

sub finalize {
  shift->{db}->finalize_bulk_insert;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Analysis::UsedModules

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
