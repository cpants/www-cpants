package WWW::CPANTS::Util::Version;

use Mojo::Base -strict, -signatures;
use Exporter qw/import/;
use version;
use Syntax::Keyword::Try;

our @EXPORT = qw/numify_version/;

sub numify_version ($version) {
    try {
        no warnings;
        my $num = version->parse($version)->numify;
        $num =~ s/_//g;
        return $num || 0;
    } catch {
        return 0;
    }
}

1;
