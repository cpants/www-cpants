package WWW::CPANTS::Process::Analysis::Provides;

use strict;
use warnings;
use WWW::CPANTS::DB;

sub new {
  bless {
    db => db('Provides')->setup,
  }, shift;
}

sub update {
  my ($self, $data) = @_;

  my %versions = %{$data->{versions} || {}};
  for my $file (keys %versions) {
    my @packages = keys $versions{$file};
    my $primary = _find_primary($file, \@packages);
    for my $package (@packages) {
      my $version = $versions{$file}{$package} // 'undef';
      my ($vnum) = $version =~ /(v?[\d.]+)/;
      $vnum = sprintf '%f', eval { version->new($vnum)->numify } || 0;
      $self->{db}->bulk_insert({
        analysis_id => $data->{id},
        author => $data->{author},
        distv => $data->{vname},
        released => $data->{released_epoch},
        package => $package,
        version => $version,
        version_num => $vnum,
        is_primary => ($package eq $primary ? 1 : 0),
      });
    }
  }
}

sub _find_primary {
  my ($file, $packages) = @_;
  if ($file =~ s!(?:^|.+/)lib/!!) {
    my $primary = $file;
    $primary =~ s!.pm$!!;
    $primary =~ s!/!::!g;
    for (@$packages) {
      return $primary if $_ eq $primary;
    }
    return ""; # hidden package etc
  } elsif ($file !~ m!/!) { # top level
    # strictly speaking, we should check PM mapping in Makefile.PL.
    my $primary = $file;
    $primary =~ s!\.pm(\.PL)?$!!i;
    my @candidates = grep /(?:^|::)$primary$/, @$packages;
    return $candidates[0] if @candidates == 1;
    return ""; # ambiguous or hidden
  }
  return "";
}

sub finalize {
  shift->{db}->finalize_bulk_insert;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Analysis::Provides

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
