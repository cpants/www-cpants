package WWW::CPANTS::Web::Data;

use WWW::CPANTS;
use WWW::CPANTS::Util;

sub new ($class, %args) { bless \%args, $class }

sub id ($self) {
    $self->{id} //= do {
        my ($name) = (ref $self || $self) =~ /^WWW::CPANTS::(Web::.+)$/;
        package_path_name($name);
    };
}

sub load ($self, @args) {
    if (@args or !-f json_file($self->id)) {
        $self->data(@args);
    } else {
        slurp_json($self->id);
    }
}

sub data ($self, @args) { return }
sub error ($self, $message = 'no data') {
    return { error => $message };
}

sub save ($self) {
    my $data = $self->data or return;
    $data->{last_updated} = time;
    save_json($self->id, $data);
    return 1;
}

sub db ($self) {
    WWW::CPANTS->context->db;
}

1;
