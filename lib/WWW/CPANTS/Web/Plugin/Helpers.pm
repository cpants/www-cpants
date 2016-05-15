package WWW::CPANTS::Web::Plugin::Helpers;

use WWW::CPANTS;
use WWW::CPANTS::Util ();
use WWW::CPANTS::Util::JSON ();
use WWW::CPANTS::Util::Kwalitee ();
use WWW::CPANTS::Web::Util::Text ();
use WWW::CPANTS::Web::Util::URL ();
use parent 'Mojolicious::Plugin';
use JavaScript::Value::Escape ();

sub register ($self, $app, $conf) {
  $app->helper(markdown => \&markdown);
  $app->helper(strftime => \&strftime);
  $app->helper(encode_json => \&encode_json);
  $app->helper(encode_pretty_json => \&encode_pretty_json);
  $app->helper(escape_js => \&escape_js);
  $app->helper(kwalitee_score => \&kwalitee_score);
  $app->helper(release_availability => \&release_availability);
  $app->helper(metacpan_url => \&metacpan_url);
  $app->helper(search_cpan_url => \&search_cpan_url);
  $app->helper(rt_url => \&rt_url);
  $app->helper(gravatar_url => \&gravatar_url);
}

sub markdown ($c, @args) {
  WWW::CPANTS::Web::Util::Text::markdown(@args);
}

sub strftime ($c, @args) {
  WWW::CPANTS::Util::strftime(@args);
}

sub encode_json ($c, $data) {
  WWW::CPANTS::Util::encode_json($data);
}

sub encode_pretty_json ($c, $data) {
  WWW::CPANTS::Util::encode_pretty_json($data);
}

sub escape_js ($c, @args) {
  JavaScript::Value::Escape::js(@args);
}

sub kwalitee_score ($c, $score) {
  WWW::CPANTS::Util::Kwalitee::kwalitee_score($score);
}

sub release_availability ($c, $dist) {
  WWW::CPANTS::Web::Util::release_availability($dist);
}

sub gravatar_url ($c, $pause_id) {
  WWW::CPANTS::Web::Util::URL::gravatar_url($pause_id);
}

sub metacpan_url ($c, $dist) {
  WWW::CPANTS::Web::Util::URL::metacpan_url($dist);
}

sub search_cpan_url ($c, $dist) {
  WWW::CPANTS::Web::Util::URL::search_cpan_url($dist);
}

sub rt_url ($c, $dist) {
  WWW::CPANTS::Web::Util::URL::rt_url($dist);
}

1;
