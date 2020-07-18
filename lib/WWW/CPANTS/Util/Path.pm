package WWW::CPANTS::Util::Path;

use Mojo::Base -strict, -signatures;
use Exporter qw/import/;
use WWW::CPANTS;

our @EXPORT = qw/cpants_app_path cpants_path/;

sub cpants_app_path ($path) {
    WWW::CPANTS->instance->app_root->child($path);
}

sub cpants_path ($path) {
    WWW::CPANTS->instance->root->child($path);
}

1;
