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
  for my $key (keys %$uses) {
    next if !$key; # ignore evaled stuff
    next if $key =~ /^v?5/; # ignore perl
    next if $key =~ /[^A-Za-z0-9_:]/; # not a valid package
    $self->{db}->bulk_insert({
      dist     => $data->{dist},
      distv    => $data->{vname},
      module   => $key,
      in_code  => $uses->{$key}{in_code} || 0,
      in_tests => $uses->{$key}{in_tests} || 0,
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
