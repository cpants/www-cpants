package WWW::CPANTS::Process::Kwalitee;

use strict;
use warnings;
use WWW::CPANTS::Log;
use Module::Find;
use Time::Piece;
use Time::Seconds;

sub new {
  my ($class, %args) = @_;

  bless \%args, $class;
}

sub update {
  my ($self, @targets) = @_;

  my %map = map { $_ => 1 } @targets;

  my %loaded;
  for my $package (findsubmod 'WWW::CPANTS::Process::Kwalitee') {
    my ($name) = $package =~ /::(\w+)$/;
    next unless !%map or $map{$name};
    eval "require $package; 1" or do { warn $@; next };
    $loaded{$name} = $package->new(%$self);
  }

  my @order = qw/
    IsCPAN
    LatestDists
    PrereqDist
    UsedModuleDist
    DistDependents
    IsPrereq
    PrereqMatchesUse
    FinalKwalitee
    AuthorStats
  /;

  for (@order) {
    next unless $loaded{$_};
    my $start = time;
    $loaded{$_}->update;
    my $end = time;
    $self->log(
      info => "Kwalitee ($_):",
        localtime($start)->strftime('%Y-%m-%d %H:%M:%S'),
        "to", localtime($end)->strftime('%Y-%m-%d %H:%M:%S'),
        "(" . Time::Seconds->new($end - $start)->pretty . ")",
    );
  }
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Kwalitee

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
