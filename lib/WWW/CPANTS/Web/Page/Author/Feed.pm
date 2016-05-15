package WWW::CPANTS::Web::Page::Author::Feed;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use WWW::CPANTS::Util::Kwalitee;
use parent 'WWW::CPANTS::Web::Data';
use XML::Atom::SimpleFeed;

sub data ($self, $pause_id = undef, @args) {
  $pause_id = is_pause_id($pause_id) or return;

  my $db = $self->db;
  my $releases = $db->table('Uploads')->select_recent_by_author($pause_id);
  my @uids = map {$_->{uid}} @$releases;
  my %kwalitee_map = map {$_->{uid} => $_} @{$db->table('Kwalitee')->select_all_by_uids(\@uids) // []};

  my $base = config('base_url');
  my $link = "$base/author/$pause_id/feed";
  my $feed = XML::Atom::SimpleFeed->new(
    -encoding => 'utf-8',
    title => "CPANTS Feed for $pause_id",
    author => "CPANTS",
    updated => datetime(@$releases ? $releases->[0]{released} : time),
    id => $link,
    link => $link,
  );

  for my $release (@$releases) {
    my $name_version = ($release->{name} // '').'-'.($release->{version});
    my $kwalitee = $kwalitee_map{$release->{uid}};
    my @fails = grep {defined $kwalitee->{$_} && !$kwalitee->{$_}} @{core_kwalitee_indicator_names()};
    my $summary = "Kwalitee: ".kwalitee_score($kwalitee->{core_kwalitee});
    $summary .= "; Core Fails: ".join ", ", @fails if @fails;
    $feed->add_entry(
      title => $name_version,
      link => "$base/release/".$release->{author}."/".$name_version,
      id => $name_version,
      summary => $summary,
      updated => datetime($release->{released}),
    );
  }
  $feed->as_string;
}

1;
