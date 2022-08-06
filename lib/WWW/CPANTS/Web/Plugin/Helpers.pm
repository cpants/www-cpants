package WWW::CPANTS::Web::Plugin::Helpers;

use Mojo::Base 'Mojolicious::Plugin', -signatures;
use WWW::CPANTS::Util::Datetime ();
use WWW::CPANTS::Web::Util::URL ();

sub register ($self, $app, $conf) {
    $app->helper(strftime             => \&strftime);
    $app->helper(release_availability => \&release_availability);
    $app->helper(metacpan_url         => \&metacpan_url);
    $app->helper(repository_url       => \&repository_url);
    $app->helper(bugtracker_url       => \&bugtracker_url);
    $app->helper(gravatar_url         => \&gravatar_url);
    $app->helper(linkify              => \&linkify);
    $app->helper(api_url              => \&api_url);
    $app->helper(svg                  => \&svg);
}

sub strftime ($c, @args) {
    WWW::CPANTS::Util::Datetime::strftime(@args);
}

sub release_availability ($c, $release) {
    return "" unless ref $release eq 'HASH';
    return "Latest Dev" if $release->{latest} && !$release->{stable};
    return "Latest"     if $release->{latest} && $release->{stable};
    return "CPAN"       if $release->{cpan};
    return "BackPAN";
}

sub gravatar_url ($c, $pause_id) {
    WWW::CPANTS::Web::Util::URL::gravatar_url($pause_id);
}

sub metacpan_url ($c, $dist) {
    WWW::CPANTS::Web::Util::URL::metacpan_url($dist);
}

sub repository_url ($c, $dist) {
    WWW::CPANTS::Web::Util::URL::repository_url($dist);
}

sub bugtracker_url ($c, $dist) {
    WWW::CPANTS::Web::Util::URL::bugtracker_url($dist);
}

sub linkify ($c, $text) {
    WWW::CPANTS::Web::Util::URL::linkify($text);
}

sub api_url ($c, $path, $query = undef) {
    $c->app->ctx->api_url($path, $query);
}

sub svg ($c, $path) {
    $path =~ s!/$!!;
    $path .= '.svg';
}

1;
