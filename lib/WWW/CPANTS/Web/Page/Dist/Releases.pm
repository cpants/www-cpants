package WWW::CPANTS::Web::Page::Dist::Releases;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use parent 'WWW::CPANTS::Web::Data';

sub data ($self, $path = undef, $page = 1, @args) {
  return unless is_path($path);
  return unless is_int($page //= 1);

  my $dist = page("Dist::Common")->load($path) or return;

  my $releases = api4('Table::ReleasesOf')->load({
    name => $dist->{name},
  }) or return;

  return {
    distribution => $dist,
    data => {
      releases => $releases->{data},
    },
    total_releases => $releases->{recordsTotal},
  };
}

1;
