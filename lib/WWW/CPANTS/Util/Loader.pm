package WWW::CPANTS::Util::Loader;

use Mojo::Base -strict, -signatures;
use Module::Find    qw/findallmod/;
use Module::Runtime ();
use Exporter 5.57   qw/import/;

our @EXPORT = qw/use_module submodules submodule_names/;
our %CACHE;

sub use_module ($name) {
    $CACHE{$name} //= Module::Runtime::use_module($name);
}

sub submodules ($namespace) {
    my %map;

    $Module::Find::followMode = 0;
    for my $package (findallmod $namespace) {
        my $name = $package =~ s/^${namespace}:://r;
        $map{$name} = $package;
    }
    \%map;
}

sub submodule_names ($namespace) {
    sort keys submodules($namespace)->%*;
}

1;
