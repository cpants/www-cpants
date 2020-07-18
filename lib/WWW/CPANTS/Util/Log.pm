package WWW::CPANTS::Util::Log;

use WWW::CPANTS;
use WWW::CPANTS::Util::Datetime;
use Exporter qw/import/;

our @EXPORT = qw/log/;

sub log ($level, $message, @args) {
    if (my $ctx = WWW::CPANTS->context) {
        $ctx->_log($level, $message, @args);
    } else {
        my $datetime = strftime('%Y-%m-%d %H:%M:%S', time);
        if (@args) {
            $message = sprintf $message, @args;
        }
        say STDERR "$datetime [$level] $message";
    }
}

1;
