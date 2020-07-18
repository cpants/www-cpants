package WWW::CPANTS::Bin::Util::Parallel;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use Parallel::Runner;
use Exporter qw/import/;

our @EXPORT = qw/parallel/;

sub parallel ($workers, $code) {
    $workers = 0 if $INC{'Devel/Cover.pm'} or $INC{'Devel/NYTProf.pm'} or $^O eq 'MSWin32';

    my $runner =
        ($workers)
        ? Parallel::Runner->new($workers)
        : WWW::CPANTS::Bin::Util::Parallel::Dummy->new($workers);

    $0 = "$^X $0 @ARGV (master)" unless $0 =~ /\((?:master|worker)\)/;

    my $runner_r = \$runner;
    local $SIG{TERM} = sub {
        warn "CAUGHT TERM";
        $$runner_r->killall('TERM');
        $$runner_r->finish;
        exit;
    };
    local $SIG{INT} = sub {
        warn "CAUGHT INT";
        $$runner_r->killall('INT');
        $$runner_r->finish;
        exit;
    };

    try { $code->($runner) }
    catch { my $error = $@; log(error => $@) }

    $runner->finish;
}

package WWW::CPANTS::Bin::Util::Parallel::Dummy;

use WWW::CPANTS;
use WWW::CPANTS::Util;

sub new ($class, $max_workers) { bless {}, $class }
sub run ($self, $code) {
    try { $code->() } catch { my $error = $@; log(error => $error) }
}
sub pid ($self) { $$ }
sub killall ($self, $sig) { kill $sig, $$ }
sub finish ($self) { }
sub max ($self)    { 1 }

1;
