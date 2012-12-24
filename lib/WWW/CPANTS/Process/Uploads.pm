package WWW::CPANTS::Process::Uploads;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Log;
use WWW::CPANTS::Parallel;
use CPAN::DistnameInfo;
use Time::Piece;
use Path::Extended;

sub new {
  my ($class, %args) = @_;
  bless \%args, $class;
}

sub update {
  my ($self, %args) = @_;

  my %dirs;
  for my $name (qw/CPAN BackPAN/) {
    my $lc_name = lc $name;
    my $path = $args{$lc_name} || $self->{$lc_name} or die "requires a $name mirror";
    my $dir = Path::Extended::Dir->new($path)->subdir("authors/id");
    die "$dir seems not a $_ mirror" unless $dir->exists;
    $dirs{$lc_name} = $dir;
  }

  db('Uploads')->setup;

  my $pm = WWW::CPANTS::Parallel->new(
    max_workers => $args{workers} || $self->{workers},
  );

  for my $subdir ('A' .. 'Z') {
    $pm->run(sub {
      $self->log(debug => "processing $subdir");
      my $db = db('Uploads');
      $dirs{backpan}->subdir($subdir)->recurse(depthfirst => 1, callback => sub {
        my $e = shift;
        return unless $e->basename =~ /\.(?:tar\.(?:gz|bz2)|tgz|zip)$/;
        my $path = $e->relative($dirs{backpan});
        my $dist = CPAN::DistnameInfo->new($path) or return;
        my $filename = $dist->filename or return;

        my $type = 'backpan';
        my $backpan_mtime = $e->mtime;
        my $cpanfile = $dirs{cpan}->file($path);
        if ($cpanfile->exists) {
          $type = 'cpan';
          my $cpan_mtime = $cpanfile->mtime;
          if ($backpan_mtime ne $cpan_mtime) {
            $self->log(warn => "mtime mismatch: $path: CPAN: $cpan_mtime BackPAN: $backpan_mtime");
          }
        }

        my $current_type = $db->fetch_current_type($path);
        if (!$current_type) {
          $db->bulk_insert({
            path => $path,
            type => $type,
            dist => $dist->dist,
            distv => $dist->distvname,
            version => $dist->version,
            author => $dist->cpanid,
            filename => $filename,
            released => $backpan_mtime,
            year => Time::Piece->new($backpan_mtime)->year,
          });
        }
        elsif ($current_type ne $type) {
          $db->update_type($type, $path);
        }
      });
      $db->finalize_bulk_insert;
      $db->finalize_update_type;
    });
  }
  $pm->wait_all_children;
}


1;

__END__

=head1 NAME

WWW::CPANTS::Process::Uploads

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
