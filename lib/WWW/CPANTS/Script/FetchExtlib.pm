package WWW::CPANTS::Script::FetchExtlib;

use strict;
use warnings;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::AppRoot;
use WorePAN;
use Archive::Any::Lite;

sub _run {
  my ($self, @dists) = @_;

  my $worepan = WorePAN->new(
    root => appdir("tmp/extlib")->path,
    use_backpan => 1,
    no_network => 0,
    cleanup => 1,
  );

  for my $dist (@dists) {
    my $file;
    if (m{^([A-Z])/\1[A-Z0-9_]/}) {
      $file = $_;
    }
    else {
      ($file) = $worepan->_dists2files({ $dist => 0 });
    }
    $self->log(debug => "fetching $file");

    $worepan->add_files($file);
    my $tarball = $worepan->file($file);
    $self->log(debug => "fetched $tarball");
    $tarball->copy_to(appdir("extlib/")->mkdir);
    my $copy = appfile("extlib/", $tarball->basename);
    $self->log(debug => "copied to $copy");
    my $archive = Archive::Any::Lite->new($copy->path);
    $archive->extract(appdir("extlib/"));

    # TODO: remove old version
  }
}

1;

__END__

=head1 NAME

WWW::CPANTS::Script::FetchExtlib - fetch an external library

=head1 SYNOPSIS

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
