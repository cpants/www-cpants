package WWW::CPANTS::Web::Page::Dist::Prereq;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use parent 'WWW::CPANTS::Web::Data';

sub data ($self, $path = undef, @args) {
  return unless is_path($path);

  my $dist = page("Dist::Common")->load($path) or return;

  my $db = $self->db;
  my $requires = $db->table('RequiresAndUses')->select_requires_by_uid($dist->{uid});

  my $requires_map = decode_json($requires // '{}');
  my @modules;
  for my $phase_type (keys %$requires_map) {
    push @modules, keys %{$requires_map->{$phase_type} // {}};
  }

  my $latest_dists = $db->table('PackagesDetails')->select_all_by_modules(\@modules);

  my %dist_map = map {$_->{module} => $_} @$latest_dists;

  my %prereqs;
  for my $phase_type (keys %$requires_map) {
    for my $module (sort keys %{$requires_map->{$phase_type} // {}}) {
      my $latest_dist = $dist_map{$module} // {};
      my $info = $latest_dist->{path} ? distinfo($latest_dist->{path}) : {};
      my $item = {
        name => $module,
        version => $requires_map->{$phase_type}{$module},
        latest_dist => $info->{distvname},
        latest_version => $info->{version},
        latest_maintainer => $info->{cpanid},
      };
      if (my $core_since = core_since($module, $requires_map->{$phase_type}{$module})) {
        $item->{core_since} = $core_since;
        if (my $deprecated = deprecated_core_since($module)) {
          $item->{deprecated_core_since} = $deprecated;
        }
        if (my $removed = removed_core_since($module)) {
          $item->{removed_core_since} = $removed;
        }
      }
      push @{$prereqs{$phase_type} //= []}, $item;
    }
  }

  return {
    distribution => $dist,
    data => \%prereqs,
  };
}

1;
