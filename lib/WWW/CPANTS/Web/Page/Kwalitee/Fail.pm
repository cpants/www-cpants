package WWW::CPANTS::Web::Page::Kwalitee::Fail;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use WWW::CPANTS::Util::Kwalitee;
use parent 'WWW::CPANTS::Web::Data';

sub data ($self, $name = '', $page = 1) {
  return unless is_kwalitee_metric($name);

  my $data = slurp_json("kwalitee/$name");
  my $failing_releases = api4('Table::FailsIn')->load({
    name => $name,
    type => 'backpan',
  });

  return {
    indicator => $data->{indicator},
    data => {
      failing_releases => $failing_releases->{data},
    },
    total_failing_releases => $failing_releases->{recordsTotal},
  };
}

1;
