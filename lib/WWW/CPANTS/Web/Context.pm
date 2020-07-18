package WWW::CPANTS::Web::Context;

use Mojo::Base -base, -signatures;
use Mojo::URL;

has 'api_ctx'  => \&_build_api_ctx;
has 'base_url' => \&_build_base_url;

sub _build_api_ctx ($self) {
    require WWW::CPANTS::API::Context;
    WWW::CPANTS::API::Context->new;
}

sub _build_base_url ($self) {
    Mojo::URL->new('https://cpants.cpanauthors.org');
}

sub api_url ($self, $path, $query = undef) {
    my $url = $self->api_ctx->api_base->clone;
    $path =~ s|^/||;
    $url->path($path);
    $url->query(%$query) if $query;
    $url;
}

1;
