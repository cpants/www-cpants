package WWW::CPANTS::DB;

use Mojo::Base -base, -signatures;
use WWW::CPANTS::Util::Loader;

has 'handle' => \&_build_handle;
has 'cache'  => sub ($self) { +{} };
has 'pid'    => sub ($self) { $$ };

sub _build_handle ($self) {
    my $config = WWW::CPANTS->instance->config->{db};
    my $name   = $config->{handle_class} // "SQLite";
    my $module = use_module("WWW::CPANTS::DB::Handle::$name");

    $module->new(
        name   => $name,
        config => $config->{$name},
        trace  => $self->trace,
    );
}

sub table ($self, $name) {
    $self->check_pid;
    if (!exists $self->cache->{$name}) {
        my $table = use_module("WWW::CPANTS::DB::Table::$name")->new;
        $table->handle($self->handle->connect($table));
        $self->cache->{$name} = $table;
    }
    $self->cache->{$name};
}

sub trace ($self, $value = undef) {
    $value //= $ENV{CPANTS_API_TRACE};
    if (defined $value) {
        $self->{trace} = $value;
        for my $name (keys $self->cache->%*) {
            $self->cache->{$name}->handle->trace($value);
        }
    }
    $self->{trace};
}

sub table_names ($self) {
    submodule_names("WWW::CPANTS::DB::Table");
}

sub check_pid ($self) {
    return if $self->pid == $$;
    $self->cache({});
    $self->pid($$);
}

1;
