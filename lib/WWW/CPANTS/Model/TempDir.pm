package WWW::CPANTS::Model::TempDir;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use File::Path::Tiny ();
use Path::Tiny       ();
use File::Temp       ();
use Syntax::Keyword::Try;
use overload
    '""'   => \&_stringify,
    '0+'   => \&_stringify,
    'bool' => \&_stringify,
    'cmp'  => \&_stringify;

our $AUTOLOAD;

has 'root' => \&_root_is_required;
has 'path' => \&_build_path;
has 'pid'  => sub ($self) { $$ };

with qw/WWW::CPANTS::Role::Logger/;

sub _root_is_required ($self) {
    Carp::confess "root is required";
}

sub _build_path ($self) {
    my $root = $self->root;
    $root->mkpath unless -d $root;
    my $path = Path::Tiny::path(File::Temp->newdir(
        DIR      => $root->path,
        TEMPLATE => join('.', time, $$, "XXXXXXXX"),
    ));
    $path->mkpath unless -d $path;
    $path;
}

sub path_str ($self) { $self->path->stringify }

sub _stringify ($self, @args) { $self->path . "" }

sub AUTOLOAD ($self, @args) {
    return if $AUTOLOAD =~ /::DESTROY$/;
    $AUTOLOAD =~ s/.*:://;
    $self->path->$AUTOLOAD(@args);
}

sub DESTROY ($self) {
    return unless $self->pid eq $$;
    my $path = $self->path;
    return unless $path && -e $path;
    try { File::Path::Tiny::rm($path) }
    catch {
        my $error = $@;
        warn "[ALERT] Failed to remove tmpdir: $error [$$] $@\n";
    }
    if (-e $path) {
        warn "[ALERT] Failed to remove tmpdir $! [$$]\n";
    }
}

1;
