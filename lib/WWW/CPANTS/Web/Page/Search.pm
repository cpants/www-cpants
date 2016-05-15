package WWW::CPANTS::Web::Page::Search;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use parent 'WWW::CPANTS::Web::Data';

sub data ($self, $name = '') {
  api4("Search")->load({name => $name});
}

sub save { return }

1;
