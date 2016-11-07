package WWW::CPANTS::Web::API::V4::Table::ReleasesOf;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use WWW::CPANTS::Util::Kwalitee;
use parent 'WWW::CPANTS::Web::Data';

sub load ($self, $params = {}) {
  my $name   = is_path($params->{name}) or return $self->error;
  my $length = is_int($params->{length}) // 25;
  my $start  = is_int($params->{start}) // 0;

  my $db = $self->db;
  my $table = $db->table('Distributions');
  my $dist = $table->select_by_name($name);
  my $uids = decode_json($dist->{uids}) // [];
  my $total = @$uids;
  my @releases = splice @$uids, $start, $length;

  my %scores = map {$_->{uid} => $_->{core_kwalitee}} @{$db->table('Kwalitee')->select_all_core_kwalitee_of([map {$_->{uid}} @releases]) // []};

  my @rows;
  for my $release (@releases) {
    $release->{$_} = html($release->{$_}) for keys %$release;
    push @rows, {
      name => $name,
      version => $release->{version},
      date => ymd($release->{released}),
      author => $release->{author},
      availability => release_availability($release),
      score => $scores{$release->{uid}},
    };
  }
  return {
    recordsTotal => $total,
    data => \@rows,
  };
}

1;
