package WWW::CPANTS::Web::Plugin::Hooks;

use Mojo::Base 'Mojolicious::Plugin', -signatures;
use Mojo::Path;
use Compress::Zlib ();

sub register ($self, $app, $conf) {
    $app->hook(before_dispatch => \&before_dispatch);
    $app->hook(after_dispatch  => \&after_dispatch);
}

sub before_dispatch ($c) {
    return if $c->req->headers->header('X-Forwarded-For');
    return unless ($c->req->headers->accept_encoding || '') =~ /gzip/i;
    my $path = $c->stash->{path} || $c->req->url->path->clone->canonicalize;
    return unless my @parts = @{ Mojo::Path->new("$path")->parts };
    return if $parts[0] eq '..';
    my $rel = join('/', @parts) . '.gz';
    if (my $file = $c->app->static->file($rel)) {
        my $type = $rel =~ /\.(\w+)\.gz$/ ? $c->app->types->type($1) : undef;
        $c->res->headers->content_type($type || 'text/plain');
        $c->res->headers->content_encoding('gzip');
        $c->app->static->serve_asset($c, $file) or return;
        $c->stash->{'mojo.static'}++;
        return !!$c->rendered;
    }
}

sub after_dispatch ($c) {
    return if $c->stash->{'mojo.static'};
    return if $c->req->headers->header('X-Forwarded-For');
    return if $c->req->is_xhr;
    return unless ($c->req->headers->accept_encoding || '') =~ /gzip/i;
    return if $c->res->content->is_multipart || $c->res->content->is_dynamic;

    my $asset = $c->res->content->asset;
    return if $asset->is_file || $asset->is_range;
    my $content = $asset->slurp;
    $c->res->headers->content_encoding('gzip');
    $c->res->body(Compress::Zlib::memGzip($content));
}

1;
