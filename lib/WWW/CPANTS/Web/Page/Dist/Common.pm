package WWW::CPANTS::Web::Page::Dist::Common;

use WWW::CPANTS;
use WWW::CPANTS::Util::Kwalitee;
use WWW::CPANTS::Web::Util;
use parent 'WWW::CPANTS::Web::Data';

sub load ($self, $path) {
  my ($author, $name_version) = split '/', $path;
  my ($name, $version);
  if ($author) {
    ($name, $version) = distname_info($name_version);
    return unless is_pause_id($author);
    return unless is_alphanum($name);
    return unless is_alphanum($version);
  } elsif (is_alphanum($name_version)) {
    $name = $name_version;
  } else {
    return;
  }

  my $db = $self->db;
  my $distributions = $db->table('Distributions');
  my $dist = $distributions->select_by_name($name) or return;
  my $uids = decode_json($dist->{uids});
  my $uid;
  if ($author) {
    for my $info (@$uids) {
      if ($info->{version} eq $version and $info->{author} eq $author) {
        $uid = $info->{uid};
        last;
      }
    }
  } else {
    $uid = $dist->{latest_dev_uid} // $dist->{latest_stable_uid};
  }
  return unless $uid;

  my $release = $db->table('Uploads')->select_by_uid($uid) or return;

  $dist->{$_} //= $release->{$_} for keys %$release;
  $dist->{latest} = 1 if $uid eq $dist->{latest_uid};
  $dist->{name_version} = join '-', $dist->{name}, $dist->{version};

  $dist->{recent_releases} = $uids;

  my $kwalitee = $db->table('Kwalitee')->select_scores_by_uid($uid);
  $dist->{core_kwalitee} = kwalitee_score($kwalitee->{core_kwalitee});
  $dist->{kwalitee} = kwalitee_score($kwalitee->{kwalitee});

  my $resources = $db->table('Resources')->select_by_uid($uid);
  if ($resources) {
    $dist->{repository_url} = $resources->{repository_url};
    $dist->{bugtracker_url} = $resources->{bugtracker_url};
    $dist->{resources} = decode_json($resources->{resources} // '{}');
  }

  $dist;
}

1;
