package WWW::CPANTS::Util::PathUid;

use Mojo::Base -strict, -signatures;
use Exporter        qw/import/;
use Digest::FNV::XS ();

our @EXPORT = qw/path_uid/;

sub path_uid ($path) {
    return unless defined $path;
    Digest::FNV::XS::fnv1a_64($path);
}

1;
