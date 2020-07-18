package WWW::CPANTS::API::Model;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use JSON::Validator;
use String::CamelCase qw/decamelize/;
use JSON::Validator;
use WWW::CPANTS::Util::Loader;

with qw(
    WWW::CPANTS::Role::Logger
);

has 'id'            => \&_build_id;
has 'path_template' => \&_build_path_template;
has 'ctx'           => sub { Carp::confess "requires ctx"; };

sub _build_id ($self) {
    my $class = ref $self || $self;
    my ($name) = $class =~ /^WWW::CPANTS::API::Model::(.+)$/;
    decamelize($name =~ s!::!/!gr);
}

sub _build_path_template ($self) {
    my $class = ref $self || $self;
    my ($name) = $class =~ /^WWW::CPANTS::API::Model::[^:]+::(.+)$/;
    return unless $name;
    my @parts = map { length $_ > 3 ? decamelize($_) : lc $_ } split '::', $name;
    join "/", "", @parts;
}

sub request_method ($self) { 'get' }

sub operation ($self) { return }

sub validate_params ($self, $params) {
    my $operation = $self->operation or return 1;

    my %schema = (
        type       => 'object',
        required   => [],
        properties => {},
    );

    for my $param ($operation->{parameters}->@*) {
        $schema{properties}{ $param->{name} } = $param;
        if ($param->{required}) {
            push $schema{required}->@*, $param->{name};
        }
        if (exists $param->{default}) {
            $params->{ $param->{name} } //= $param->{default};
        }
    }
    my $validator = JSON::Validator->new;
    $validator->schema(\%schema);
    if (my @errors = $validator->validate($params)) {
        return wantarray ? (undef, \@errors) : undef;
    }
    return 1;
}

sub bad_request ($self, $errors, $status = 400) {
    $errors = [$errors] unless ref $errors eq 'ARRAY';
    $self->log(info => $_) for @$errors;
    return unless wantarray;
    return (undef, +{ errors => $errors, status => $status });
}

sub internal_error ($self, $errors) {
    $errors = [$errors] unless ref $errors eq 'ARRAY';
    $self->log(error => $_) for @$errors;
    return unless wantarray;
    return (undef, +{ errors => $errors, status => 500 });
}

sub load ($self, $params = {}, $validated = 0) {
    if (!$validated) {
        my ($ok, $errors) = $self->validate_params($params);
        return $self->bad_request($errors) if $errors;
    }

    if (!$params and -f json_file($self->id)) {
        return slurp_json($self->id);
    }
    $self->_load($params);
}

sub _load ($self, $params = undef) { return; }

sub save ($self) { return }

sub db ($self) { $self->ctx->db; }

sub model ($self, $name) {
    my $class = "WWW::CPANTS::API::Model::$name";
    use_module($class)->new(ctx => $self->ctx);
}

1;
