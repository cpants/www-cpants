use strict;
use warnings;
use lib "lib";

WWW::CPANTS::Script::fetch_extlib->run_directly;

package WWW::CPANTS::Script::fetch_extlib;
use base 'WWW::CPANTS::Script::Base';
use WorePAN;
use Archive::Any::Lite;
use Path::Extended;
use WWW::CPANTS::AppRoot;

sub run {
  my ($self, @dists) = @_;

  my $worepan = WorePAN->new(
    root => appdir("tmp/extlib")->path,
    use_backpan => 1,
    no_network => 0,
    cleanup => 1,
  );

  for (@dists) {
    my $file;
    if (m{^([A-Z])/\1[A-Z0-9_]/}) {
      $file = $_;
    }
    else {
      ($file) = $worepan->_dists2files({ $_ => 0 });
    }

    $worepan->add_files($file);
    my $tarball = $worepan->file($file);
    $tarball->copy_to(appdir("extlib/"));
    my $copy = appfile("extlib/", $tarball->basename);
    my $archive = Archive::Any::Lite->new($copy->path);
    $archive->extract(appdir("extlib/"));
  }
}
