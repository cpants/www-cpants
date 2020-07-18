package WWW::CPANTS::Util::Diff;

use Mojo::Base -strict, -signatures;
use Exporter qw/import/;

our @EXPORT = qw/diff/;

if (eval { require Text::Diff::Unified::XS; 1 }) {
    *diff = \&_xs_diff;
} else {
    require Text::Diff;
    *diff = \&_pp_diff;
}

sub _xs_diff ($old, $new) {
    Text::Diff::Unified::XS::diff($old, $new);
}

sub _pp_diff ($old, $new) {
    Text::Diff::diff($old, $new, { STYLE => 'Unified' });
}

1;

