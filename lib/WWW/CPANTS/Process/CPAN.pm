package WWW::CPANTS::Process::CPAN;

use strict;
use warnings;
use WWW::CPANTS::DB::Authors;
use WWW::CPANTS::DB::Packages;
use WWW::CPANTS::Log;
use WWW::CPANTS::Extlib;
use WorePAN;
use CPAN::DistnameInfo;

sub new {
  my ($class, %args) = @_;

  WWW::CPANTS::DB::Authors->new->setup;
  WWW::CPANTS::DB::Packages->new->setup;

  bless \%args, $class;
}

sub update {
  my ($self, %args) = @_;

  # backpan is not suitable for this process
  my $cpan = $args{cpan} || $self->{cpan} or die "requires cpan";
  my $worepan = WorePAN->new(root => $cpan);

  $self->_update_authors($worepan);
  $self->_update_packages($worepan);
}

sub _update_authors {
  my ($self, $worepan) = @_;

  if (!$worepan->whois->exists) {
    $self->log(debug => "downloading whois");
    require HTTP::Tiny;
    my $ua = HTTP::Tiny->new;
    my $res = $ua->mirror("http://cpan.cpanauthors.org/authors/00whois.xml", $worepan->whois."");
    unless ($res->{success}) {
      die "$res->{status} $res->{reason}";
    }
  }

  my $db = WWW::CPANTS::DB::Authors->new;
  $db->mark;
  my $ct = 0;
  for (@{ $worepan->authors || [] }) {
    $db->bulk_insert($_);
    $self->log(debug => "updated $ct authors") unless ++$ct % 1000;
  }
  $db->finalize_bulk_insert;
  $db->unmark;
}

sub _update_packages {
  my ($self, $worepan) = @_;

  my $db = WWW::CPANTS::DB::Packages->new;
  my $ct = 0;

  $db->mark;
  for (@{ $worepan->modules || [] }) {
    die "worepan or CPAN index seems broken" unless $_->{file};
    my $info = CPAN::DistnameInfo->new($_->{file});
    $_->{dist} = $info->dist or next;  # ignore .pm.gz etc
    $_->{distv} = $info->distvname;
    $_->{author} = $info->cpanid;
    $db->bulk_insert($_);
    $self->log(debug => "updated $ct packages") unless ++$ct % 1000;
  }
  $db->finalize_bulk_insert;
  $db->unmark;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::CPAN

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
