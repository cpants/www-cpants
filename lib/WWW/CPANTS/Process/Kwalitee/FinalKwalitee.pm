package WWW::CPANTS::Process::Kwalitee::FinalKwalitee;

use strict;
use warnings;
use WWW::CPANTS::Log;
use WWW::CPANTS::DB;
use WWW::CPANTS::Kwalitee;

sub new {
  my ($class, %args) = @_;
  bless \%args, $class;
}

sub update {
  my $self = shift;

  $self->log(debug => "updating kwalitee scores");

  my $kwalitee_db = db('Kwalitee');
  my @metrics = kwalitee_metrics();
  if (!@metrics) {
    save_metrics();
    @metrics = kwalitee_metrics();
  }

  my $num_of_core_indicators = 0;
  my (@core, @extra);
  for (kwalitee_metrics()) {
    if ($_->{is_experimental}) {
      next;
    }
    elsif ($_->{is_extra}) {
      push @extra, $_->{name};
    }
    else {
      push @core, $_->{name};
      $num_of_core_indicators++;
    }
  }

  my $ct = 0;
  while(my $row = $kwalitee_db->iterate) {
    my $core  = 0;
    my $extra = 0;
    for (@core) {
      $core++ if $row->{$_};
    }
    for (@extra) {
      $extra++ if $row->{$_};
    }
    $extra += $core;

    my $kwalitee = 100 * $extra / $num_of_core_indicators;
    my $core_kwalitee = 100 * $core / $num_of_core_indicators;

    if (
      (($row->{kwalitee} || 0) != $kwalitee) or
      (($row->{core_kwalitee} || 0) != $core_kwalitee)
    ) {
      $row->{kwalitee} = $kwalitee;
      $row->{core_kwalitee} = $core_kwalitee;
      $kwalitee_db->update_final_kwalitee($row);
    }
    $self->log(debug => "updated $ct kwalitee") unless ++$ct % 1000;
  }
  $kwalitee_db->finalize_update_final_kwalitee;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Kwalitee::FinalKwalitee

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 update

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
