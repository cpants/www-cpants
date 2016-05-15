package WWW::CPANTS::Web::Page::Home;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use parent 'WWW::CPANTS::Web::Data';

sub data ($self, @args) {
  my $releases = api4('Table::Recent')->load({});

  return {
    data => {
      releases => $releases->{data},
    },
  };
}

1;
