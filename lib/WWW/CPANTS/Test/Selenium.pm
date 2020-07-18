package WWW::CPANTS::Test::Selenium;

use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Web;
use Test::More;
use Test::TCP;
use Plack::Runner;
use Plack::Builder;
use Plack::App::Directory;
use File::Which qw/which/;
use URI;
use URI::QueryParam;

use constant MY_HOST => $ENV{TRAVIS} ? $ENV{HOSTNAME} : '127.0.0.1';

our %EXTRA = (
    "Selenium::Chrome" => {
        'goog:chromeOptions' => {
            args => [
                'headless',             'enable-logging',
                'window-size=1280,800', 'no-sandbox',
            ],
            perfLoggingPrefs => {},
        },
        loggingPrefs => { performance => 'ALL' },
        binaries     => [
            'chromedriver',
            '/usr/bin/chromedriver',
            '/usr/lib/chromium-browser/chromedriver',
            '/usr/lib64/chromium-browser/chromedriver',
        ],
    },
    "Selenium::Remote::Driver" => {
        'goog:chromeOptions' => {
            args => [
                'headless',             'enable-logging',
                'window-size=1280,800', 'no-sandbox',
            ],
        },
        travis => {
            remote_server_addr => 'chromedriver',
            port               => 9515,
        },
    },
);

sub new ($class) {
    my $driver_class = $ENV{TRAVIS} ? 'Selenium::Remote::Driver' : 'Selenium::Chrome';
    eval "require $driver_class" or plan skip_all => "No $driver_class";

    # for recent chromedriver
    $Selenium::Remote::Driver::FORCE_WD2 = 1;

    my $extra = $EXTRA{$driver_class} || {};

    my %driver_opts = (
        auto_close          => 1,
        default_finder      => 'css',
        extra_capabilities  => $extra,
        acceptInsecureCerts => 1,
        timeout             => 10,
        debug               => 1,
        custom_args         => "--log-path=/home/ishigaki/www/CPANTS-API/log_file --verbose",
    );
    for my $binary (@{ delete $extra->{binaries} || [] }) {
        $binary = _fix_binary($binary) or next;
        $driver_opts{binary} = $binary;
        last;
    }

    my $travis_config = delete $extra->{travis};
    if ($ENV{TRAVIS}) {
        %driver_opts = (%driver_opts, %$travis_config);
    }

    use Path::Tiny;
    my $driver = eval { $driver_class->new(%driver_opts) }
        or plan skip_all => "Failed to instantiate $driver_class: $@\n" . path('/home/ishigaki/www/CPANTS-API/log_file')->slurp;

    my $server = Test::TCP->new(
        code => sub {
            my $port = shift;

            my $builder = builder {
                mount "/public" => builder {
                    enable 'AccessLog';
                    Plack::App::Directory->new(root => "./public");
                },
                    mount "/" => builder {
                    enable 'AccessLog';
                    WWW::CPANTS::Web->new->start('psgi');
                    },
            };
            my $runner = Plack::Runner->new(app => $builder);
            $runner->parse_options(
                '--port'   => $port,
                '--env'    => 'development',
                '--server' => 'Standalone',
            );
            $runner->run;
        },
    );

    my $port     = $server->port;
    my $host     = MY_HOST;
    my $base_url = URI->new("http://$host:$port");

    bless {
        server   => $server,
        base_url => $base_url,
        driver   => $driver,
        pid      => $$,
    }, $class;
}

sub _fix_binary {
    my $binary = shift;
    if (File::Spec->file_name_is_absolute($binary)) {
        return $binary if -e $binary && -x _;
    } else {
        which($binary);
    }
}

sub driver { shift->{driver} }

sub base_url {
    my $self = shift;
    $self->{base_url}->clone;
}

sub DESTROY {
    my $self = shift;
    return unless $self->{pid} eq $$;
    my $driver = $self->{driver} or return;
    $driver->quit;
}

1;
