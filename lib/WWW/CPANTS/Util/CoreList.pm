package WWW::CPANTS::Util::CoreList;

use WWW::CPANTS;
use Exporter qw/import/;
use Module::CoreList;

our @EXPORT = qw/is_core core_since removed_core_since deprecated_core_since/;
our $MinPerlVersion = 5.008001;

sub is_core ($module, $perl_version = $MinPerlVersion) {
  Module::CoreList::is_core($module, undef, $perl_version);
}

sub core_since ($module, $version = 0) {
  Module::CoreList::first_release($module, $version);
}

sub removed_core_since ($module) {
  Module::CoreList::removed_from($module);
}

sub deprecated_core_since ($module) {
  Module::CoreList::deprecated_in($module);
}

1;
