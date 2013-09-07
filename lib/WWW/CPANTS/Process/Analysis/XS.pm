package WWW::CPANTS::Process::Analysis::XS;

use strict;
use warnings;
use WWW::CPANTS::DB;

sub new {
  bless {
    db => db('XS')->setup,
  }, shift;
}

sub update {
  my ($self, $data) = @_;

  my %xs;
  for (@{$data->{files_array} || []}) {
    if (/\.(xs|c|cpp)$/) {
      $xs{"has_".$1} = 1;
    }
    elsif (/ppport\.h$/) {
      $xs{has_ppport_h} = 1;
    }
  }

  return unless %xs;

  $self->{db}->bulk_insert({
    analysis_id => $data->{id},
    author => $data->{author},
    released => $data->{released_epoch},
    (map { ($_ => $xs{$_} || 0) }
     qw/has_xs has_c has_cpp has_ppport_h/),
  });
}

sub finalize {
  shift->{db}->finalize_bulk_insert;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Analysis::XS

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 update
=head2 finalize

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
