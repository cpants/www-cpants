package WWW::CPANTS::Bin::Util;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use WWW::CPANTS::Bin::Util::Timer;
use Exporter qw/import/;
use version;

our @EXPORT = (
    @WWW::CPANTS::Util::EXPORT,
    qw/
        timer
        numify_version
        /,
);

sub timer ($name) {
    WWW::CPANTS::Bin::Util::Timer->new($name);
}

sub numify_version ($version) {
    my $num = eval { no warnings; version->parse($version)->numify };
    return if $@;
    $num =~ s/_//g;
    return $num;
}

1;
