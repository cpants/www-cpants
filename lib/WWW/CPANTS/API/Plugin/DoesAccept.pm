package WWW::CPANTS::API::Plugin::DoesAccept;

use Mojo::Base 'Mojolicious::Plugin', -signatures;

sub register ($self, $app, $conf) {
    $app->helper(does_accept => \&does_accept);
}

sub does_accept ($c, $type) {
    my @accepts = split ',', $c->req->headers->accept // '';
    for my $accept (@accepts) {
        return 1 if $accept =~ /\A$type(;|$)/;
    }
    return;
}

1;
