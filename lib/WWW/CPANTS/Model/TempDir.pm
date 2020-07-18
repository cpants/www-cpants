package WWW::CPANTS::Model::TempDir;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use Path::Tiny ();
use File::Temp ();
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
    try { rm($path) }
    catch {
        my $error = $@;
        warn "[ALERT] Failed to remove tmpdir: $error [$$] $@\n";
    }
    if (-e $path) {
        warn "[ALERT] Failed to remove tmpdir $! [$$]\n";
    }
}

# Until File::Path::Tiny is fixed...
# (taken from File::Path::Tiny 0.09)
sub rm ($path) {
    my ($orig_dev, $orig_ino) = (lstat $path)[0, 1];
    if (-e _ && !-d _) { $! = 20; return; }
    return 2 if !-d _;

    empty_dir($path) or return;
    _bail_if_changed($path, $orig_dev, $orig_ino);
    rmdir($path) or !-e $path or return;
    return 1;
}

sub empty_dir ($path) {
    my ($orig_dev, $orig_ino) = (lstat $path)[0, 1];
    if (-e _ && !-d _) { $! = 20; return; }

    opendir(DIR, $path) or return;
    my @contents = grep { $_ ne '.' && $_ ne '..' } readdir(DIR);
    closedir DIR;
    _bail_if_changed($path, $orig_dev, $orig_ino);

    for my $thing (@contents) {
        my $long = "$path/$thing";
        if (!-l $long && -d _) {
            _bail_if_changed($path, $orig_dev, $orig_ino);
            rm($long) or !-e $long or return;
        } else {
            _bail_if_changed($path, $orig_dev, $orig_ino);
            unlink $long or !-e $long or return;
        }
    }

    _bail_if_changed($path, $orig_dev, $orig_ino);

    return 1;
}

sub _bail_if_changed ($path, $orig_dev, $orig_ino) {
    my ($cur_dev, $cur_ino) = (lstat $path)[0, 1];

    if (!defined $cur_dev || !defined $cur_ino) {
        $cur_dev ||= "undef(path went away?)";
        $cur_ino ||= "undef(path went away?)";
    } else {
        $path = Cwd::abs_path($path);
    }

    if ($orig_dev ne $cur_dev || $orig_ino ne $cur_ino) {
        local $Carp::CarpLevel += 1;
        Carp::croak("directory $path changed: expected dev=$orig_dev ino=$orig_ino, actual dev=$cur_dev ino=$cur_ino, aborting");
    }
}

1;
