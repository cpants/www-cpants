package WWW::CPANTS::Process::Permissions;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Log;

sub new {
  my ($class, %args) = @_;
  bless \%args, $class;
}

sub update {
  my $self = shift;
  my $cpan = $self->{cpan} or die "requires CPAN mirror";
  my $file = Path::Extended::Dir->new($cpan)->file("modules/06perms.txt");
  unless ($file->exists) {
    $self->log(debug => "downloading 06perms.txt.gz");
    my $gzfile = Path::Extended::File->new($file.".gz");
    require Furl::HTTP;
    my $ua = Furl::HTTP->new;
    $gzfile->openw;
    $gzfile->binmode;
    my (undef, $code, $msg) = $ua->request(
      url => "http://www.cpan.org/modules/06perms.txt.gz",
      write_file => $gzfile->_handle,
    );
    $gzfile->close;
    if ($code =~ /^2/ and $gzfile->size) {
      require IO::Uncompress::Gunzip;
      IO::Uncompress::Gunzip::gunzip("$gzfile" => "$file") or die "gunzip failed: $IO::Uncompress::Gunzip::GunzipError";
      $gzfile->unlink;
      $self->log(debug => "gunzipped 06perms.txt.gz");
    }
  }

  my $seen_header;
  my %map;
  $file->openr;
  while(<$file>) {
    chomp;
    if (/^$/ and !$seen_header) {
      $seen_header = 1;
      next;
    }
    next unless $seen_header;
    my ($package, $id, $type) = split /,/;
    push @{$map{$id} ||= []}, $package;
  }

  my $db = db('Permissions')->setup;
  for (keys %map) {
    $db->bulk_insert({
      author => $_,
      packages => join(',', @{$map{$_}}),
    });
  }
  $db->finalize_bulk_insert;
  $file->close;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Permissions

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 update

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
