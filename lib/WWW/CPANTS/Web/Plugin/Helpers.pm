package WWW::CPANTS::Web::Plugin::Helpers;

use Mojo::Base 'Mojolicious::Plugin', -signatures;
use WWW::CPANTS::Util::Datetime ();
use WWW::CPANTS::Web::Util::URL ();
use WWW::CPANTS::Util::JSON     ();
use Scalar::Util                qw(blessed);
use Mojo::DOM::HTML             qw(tag_to_html);
use Mojo::ByteStream;

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
    $app->helper(encode_json          => \&encode_json);
    $app->helper(script               => \&script);
    $app->helper(css                  => \&css);
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

sub encode_json ($c, $data) {
    WWW::CPANTS::Util::JSON::encode_json($data);
}

# adopted Mojolicious::Plugin::TagHelpers::_javascript not to add CDATA
sub script ($c, @args) {
    my $content = ref $args[-1] eq 'CODE' ? pop(@args)->() : '';
    my @src;
    if (@args % 2) {
        my $url = shift @args;
        my $src  = blessed $url && $url->isa('Mojo::URL') ? $url : $c->url_for_file($url);
        $src->query([$c->app->mode eq 'development' ? (ts => time) : (v => $WWW::CPANTS::VERSION)]);
        @src = (src => $src);
    }
    return Mojo::ByteStream->new(tag_to_html('script', @src, @args, sub { $content }));
}

# adopted Mojolicious::Plugin::TagHelpers::_stylesheet not to add CDATA
sub css ($c, @args) {
    my $content = ref $args[-1] eq 'CODE' ? pop(@args)->() : '';
    return Mojo::ByteStream->new(tag_to_html('style', @args, sub {$content})) unless @args % 2;

    my $url = shift @args;
    my $link = blessed $url && $url->isa('Mojo::URL') ? $url : $c->url_for_file($url);
    $link->query([$c->app->mode eq 'development' ? (ts => time) : (v => $WWW::CPANTS::VERSION)]);

    return Mojo::ByteStream->new(tag_to_html('link', rel => 'stylesheet', href => $link, @args));
}

1;
