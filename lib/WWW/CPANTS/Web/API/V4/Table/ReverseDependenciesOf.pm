package WWW::CPANTS::Web::API::V4::Table::ReverseDependenciesOf;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use WWW::CPANTS::Util::Kwalitee;
use parent 'WWW::CPANTS::Web::Data';

sub load ($self, $params = {}) {
  my $name   = is_dist($params->{name}) or return $self->error;
  my $length = is_int($params->{length}) // 50;
  my $start  = is_int($params->{start}) // 0;

  my $db = $self->db;
  my $dist = $db->table('Distributions')->select_by_name($name) or return $self->error;
  my @used_by = @{decode_json($dist->{used_by} // '[]')};
  my $total = @used_by;

  my @names = map {$_->[0]} splice @used_by, $start, $length;
  my @uids = map {$_->{latest_dev_uid} // $_->{latest_stable_uid}}
    @{$db->table('Distributions')->select_all_latest_uids_by_name(\@names) // []};
  my %score = map {$_->{uid} => $_->{core_kwalitee}}
    @{$db->table('Kwalitee')->select_all_core_kwalitee_of(\@uids) // []};
  my @dists = map {+{
    name_version => html($_->{name}.'-'.$_->{version}),
    author => html($_->{author}),
    date => ymd($_->{released}),
    score => $score{$_->{uid}},
  }} sort {$b->{released} <=> $a->{released}} @{$db->table('Uploads')->select_all_by_uid(\@uids) // []};
  return {
    recordsTotal => $total,
    data => \@dists,
  };
}

1;
