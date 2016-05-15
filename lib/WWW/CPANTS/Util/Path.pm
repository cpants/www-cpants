package WWW::CPANTS::Util::Path;

use WWW::CPANTS;
use Exporter qw/import/;
use Path::Tiny ();

our @EXPORT = qw/file dir app_file app_dir tmp_dir/;

our ($ROOT, $TEST_ROOT);

sub app_root () {
  $ROOT //= do {
    my $dir = Path::Tiny::path(__FILE__);
    until ($dir->child('Makefile.PL')->exists) {
      croak "Can't find app root\n" if $dir eq $dir->parent;
      $dir = $dir->parent;
    }
    $dir->realpath;
  };
}

sub root () {
  if ($ENV{HARNESS_ACTIVE}) {
    $TEST_ROOT //= do {
      my $dir = app_dir("tmp/test"); $dir->mkpath;
      WWW::CPANTS::Util::Path::Tempdir->new($dir);
    };
    return $TEST_ROOT;
  }
  return app_root();
}

END {
  undef $TEST_ROOT;
}

sub tmp_dir (@parts) {
  my $dir = dir("tmp", @parts); $dir->mkpath;
  WWW::CPANTS::Util::Path::Tempdir->new($dir);
}

sub app_file (@parts) { _path(app_root(), @parts) }
sub app_dir (@parts)  { _path(app_root(), @parts) }
sub file (@parts)     { _path(root(), @parts) }
sub dir (@parts)      { _path(root(), @parts) }

sub _path ($root, @parts) {
  my $_root = ($parts[0] && ref $parts[0] && $parts[0]->is_absolute) ? shift @parts : $root;
  my $path = $_root->child(@parts);
  $root->subsumes($path) ? $path : croak "external path: $path\n";
}

package WWW::CPANTS::Util::Path::Tempdir;

use WWW::CPANTS;
use Path::Tiny ();
use File::Temp ();
use overload
  '""' => \&_dir,
  '0+' => \&_dir,
  'bool' => \&_dir,
  'cmp' => \&_dir;

our $AUTOLOAD;

sub new ($class, $parent_dir) {
  my $tmpdir = Path::Tiny::path(File::Temp::tempdir(
    DIR => $parent_dir->path,
    TEMPLATE => join('.', time, $$, "XXXXXXXX"),
  ));
  bless {pid => $$, dir => $tmpdir}, $class;
}

sub DESTROY ($self) {
  if ($self->{pid} eq $$ && $self->{dir}) {
    $self->{dir}->remove_tree({safe => 0});
  }
}

sub _dir ($self_r, @args) { ${$self_r}{dir} }

sub AUTOLOAD ($self, @args) {
  return if $AUTOLOAD =~ /::DESTROY$/;
  $AUTOLOAD =~ s/.*:://;
  $self->{dir}->$AUTOLOAD(@args);
}

1;
