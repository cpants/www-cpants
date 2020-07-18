package WWW::CPANTS::Role::CPAN::Indices;

use Mojo::Base -role, -signatures;
use WWW::CPANTS::Model::CPAN::Packages;
use WWW::CPANTS::Model::CPAN::Perms;
use WWW::CPANTS::Model::CPAN::Whois;
use WWW::CPANTS::Model::CPAN::Recent;

requires 'root';

has 'packages' => \&_build_packages;
has 'perms'    => \&_build_perms;
has 'whois'    => \&_build_whois;
has 'recent'   => \&_build_recent;

sub indices ($self) {
    my @indices = map { $self->$_ } qw/packages perms whois recent/;
    \@indices;
}

sub _build_packages ($self) {
    WWW::CPANTS::Model::CPAN::Packages->new(root => $self->root);
}

sub _build_perms ($self) {
    WWW::CPANTS::Model::CPAN::Perms->new(root => $self->root);
}

sub _build_whois ($self) {
    WWW::CPANTS::Model::CPAN::Whois->new(root => $self->root);
}

sub _build_recent ($self) {
    WWW::CPANTS::Model::CPAN::Recent->new(root => $self->root);
}

1;
