package WWW::CPANTS::Model::CPAN::Recent;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use WWW::CPANTS::Util::JSON;
use Class::Method::Modifiers;

with qw/WWW::CPANTS::Role::CPAN::Index/;

has 'root'          => \&_root_is_required;
has 'type'          => '6h';
has 'path'          => \&_build_path;
has 'file'          => \&_build_file;
has 'distributions' => \&_build_distributions;

our %Types = map { $_ => 1 } qw/1M 1Q 1W 1Y 1d 1h 6h Z/;

before 'type' => sub ($self, @args) {
    return unless @args;
    my $type = $args[0];
    Carp::croak "Invalid type: $type" unless exists $Types{$type};
};

sub _root_is_required ($self) {
    Carp::confess "root is required";
}

sub _build_path ($self) {
    my $type = $self->type;
    return "RECENT-$type.json";
}

sub _build_file ($self) {
    $self->root->child($self->path);
}

sub _build_distributions ($self) {
    my $file = $self->fetch;

    decode_json($file->slurp_utf8)->{recent};
}

sub preload ($self) { $self->distributions }

1;
