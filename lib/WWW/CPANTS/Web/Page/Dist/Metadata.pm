package WWW::CPANTS::Web::Page::Dist::Metadata;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use parent 'WWW::CPANTS::Web::Data';

sub data ($self, $path = undef, @args) {
  return unless is_path($path);

  my $dist = page("Dist::Common")->load($path) or return;

  my $db = $self->db;
  my $json = $db->table('Analysis')->select_json_by_uid($dist->{uid});

  return {
    distribution => $dist,
    data => {
      metadata => $json // '{}',
    },
  };
}

1;
