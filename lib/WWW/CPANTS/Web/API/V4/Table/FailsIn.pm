package WWW::CPANTS::Web::API::V4::Table::FailsIn;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use WWW::CPANTS::Util::Kwalitee;
use parent 'WWW::CPANTS::Web::Data';

sub load ($self, $params = {}) {
  my $name   = is_kwalitee_metric($params->{name}) or return $self->error;
  my $type   = is_availability_type($params->{type} // 'latest') or return $self->error;
  my $length = is_int($params->{length}) // 25;
  my $start  = is_int($params->{start}) // 0;

  my $db = $self->db;
  my $table = $db->table('Kwalitee');
  my $uids = $table->fails_in($name, $type, $length, $start);
  my $total = $table->count_fails_in($name, $type);
  my %releases = map {$_->{uid} => $_} @{$db->table('Uploads')->select_all_by_uid($uids) // []};

  my @rows;
  for my $uid (@$uids) {
    my $release = $releases{$uid};
    if (!$release) {
      log(info => "$uid is not found in uploads");
      next;
    }
    $release->{$_} = html($release->{$_}) for keys %$release;
    my $name_version = $release->{name} . (defined $release->{version} ? '-'.$release->{version} : '');
    push @rows, {
      name_version => $name_version,
      author => $release->{author},
      date => ymd($release->{released}),
      availability => release_availability($release),
    };
  }

  return {
    recordsTotal => $total,
    data => \@rows,
  };
}

1;
