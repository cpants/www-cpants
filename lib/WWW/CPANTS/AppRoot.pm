package WWW::CPANTS::AppRoot;

use strict;
use warnings;
use Exporter::Lite;
use Path::Extended::File;
use File::Temp qw/tempdir/;

our @EXPORT = qw/file dir appfile appdir/;

our ($ROOT, $TESTROOT);

sub approot {
  $ROOT ||= do {
    my $dir = Path::Extended::File->new(__FILE__)->parent;
    until ($dir->file('Makefile.PL')->exists) {
      die "Can't find app root\n" if $dir eq $dir->parent;
      $dir = $dir->parent;
    }
    $dir;
  };
}

sub root {
  if ($ENV{HARNESS_ACTIVE}) {
    $TESTROOT ||= do {

      appdir(tempdir(DIR => appdir('tmp')->mkdir->path, CLEANUP => 1));
    };
    return $TESTROOT;
  }
  return __PACKAGE__->approot;
}

sub appfile { _file(__PACKAGE__->approot, @_) }
sub appdir  { _dir(__PACKAGE__->approot, @_) }
sub file    { _file(__PACKAGE__->root, @_) }
sub dir     { _dir(__PACKAGE__->root, @_) }

sub _file {
  my $root = shift;
  my $file = $root->file(@_);
  $root->subsumes($file) ? $file : die "external file: $file\n";
}

sub _dir {
  my $root = shift;
  my $dir = $root->subdir(@_);
  $root->subsumes($dir) ? $dir : die "external dir: $dir\n";
}

1;

__END__

=head1 NAME

WWW::CPANTS::AppRoot

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 approot
=head2 appfile
=head2 appdir
=head2 root
=head2 file
=head2 dir

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
