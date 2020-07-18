use Modern::Perl;
use experimental 'signatures';
use FindBin;
use lib "$FindBin::Bin/../lib";
use Plack::Builder;
use WWW::CPANTS::Util;
use WWW::CPANTS::Web;

local $ENV{MOJO_REVERSE_PROXY} = 1;
local $ENV{MOJO_HOME}          = "$FindBin::Bin";

my $app = WWW::CPANTS::Web->new;

builder {
    if ($app->mode eq 'production') {
        my $counter_file = $app->home->rel_file('tmp/counter');
        my $scoreboard   = $app->home->rel_file('tmp/scoreboard');
        unless (-d $scoreboard) {
            require File::Path;
            File::Path::mkpath($scoreboard);
        }
        enable "ReverseProxy";
        enable "ServerStatus::Lite",
            path         => '/server-status',
            allow        => config('local_addr'),
            counter_file => $counter_file,
            scoreboard   => $scoreboard;
    }
    enable "AxsLog",
        combined           => 1,
        response_time      => 1,
        long_response_time => 1000000,
        logger             => sub { log(alert => @_) };
    $app->start('psgi');
};
