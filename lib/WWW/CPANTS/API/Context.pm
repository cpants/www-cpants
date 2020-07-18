package WWW::CPANTS::API::Context;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use WWW::CPANTS;
use WWW::CPANTS::DB;
use WWW::CPANTS::Util::Loader;
use WWW::CPANTS::Model::Kwalitee;
use Mojo::URL;

with qw(
    WWW::CPANTS::Role::Logger
    WWW::CPANTS::Role::Options
);

our @OPTIONS = (
    'trace:1',
    'verbose|v',
);

has 'db'       => \&_build_db;
has 'quiet'    => \&_build_quiet;
has 'kwalitee' => \&_build_kwalitee;
has 'api_base' => \&_build_api_base;

sub _build_db ($self) {
    WWW::CPANTS::DB->new(trace => $self->trace);
}

sub _build_quiet ($self) {
    return if $self->verbose;
    WWW::CPANTS->instance->quiet;
}

sub _build_kwalitee ($self) {
    WWW::CPANTS::Model::Kwalitee->new;
}

sub _build_api_base ($self) {
    my $base = WWW::CPANTS->instance->config->{api_base} // '/api/';
    $base .= '/' unless substr($base, -1, 1) eq '/';
    Mojo::URL->new($base);
}

1;
