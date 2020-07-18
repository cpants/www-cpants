package WWW::CPANTS::Context;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use WWW::CPANTS::DB;

our %ModeAlias = (
    devel   => 'development',
    develop => 'development',
);

sub new ($class, $app_name, %args) {
    bless {
        name        => $app_name,
        args        => \%args,
        error_state => {},
        stash       => {},
        pid         => $$,
    }, $class;
}

sub name ($self) { $self->{name} }

sub option ($self, $name) {
    exists $self->{opts}{$name} ? $self->{opts}{$name} : undef;
}

sub mode ($self) {
    my $mode = $self->{opts}{mode} // $self->_config('mode') // $^O eq 'MSWin32' ? 'development' : 'production';
    $mode = 'development' if $self->{opts}{debug};
    exists $ModeAlias{$mode} ? $ModeAlias{$mode} : $mode;
}

sub _mode_is ($self, $mode) {
    $self->mode eq (exists $ModeAlias{$mode} ? $ModeAlias{$mode} : $mode) ? 1 : 0;
}

sub db ($self) {
    if ($self->{pid} eq $$) {
        $self->{db} //= $self->new_db;
    } else {
        $self->new_db;
    }
}

sub new_db ($self) {
    unless ($self->{db_config}) {
        my %db_config;
        for my $key (keys %{ $self->{config}{db} // {} }) {
            $db_config{$key} = $self->{config}{db}{$key};
        }
        for my $key (keys %{ $self->{opts} // {} }) {
            $db_config{$1} = $self->{opts}{$1} if $key =~ /^db_(.+)/;
        }
        $self->{db_config} = \%db_config;
    }
    WWW::CPANTS::DB->new($self->{db_config});
}

sub load_config ($self) {
    $self->{config} //= do {
        my $file      = file("etc/config.pl");
        my $conf      = -f $file ? do $file : {};
        my $mode      = $self->mode;
        my $mode_file = file("etc/$mode.pl");
        if (-f $mode_file) {
            my $mode_conf = do $mode_file;
            $conf->{$_} = $mode_conf->{$_} for %$mode_conf;
        }

        my %default = (
            cpan_dir    => "$ENV{HOME}/cpan",
            backpan_dir => "$ENV{HOME}/backpan",
            cpan_url    => "http://cpan.cpanauthors.org",
            backpan_url => "http://backpan.cpanauthors.org",
            base_url    => "http://cpants.cpanauthors.org",
            local_addr  => ["127.0.0.1"],

            # FIXME! move to Web::Context
            font => {
                size => 11,
                (
                      ($^O eq 'MSWin32') ? (face => 'Meiryo UI')
                    : ($^O eq 'darwin')  ? (file => '/Library/Fonts/Verdana.tff')
                    :                      (file => '/usr/share/fonts/truetype/ttf-dejavu/DejaVuSans.ttf')
                ),
            },
        );
        $conf->{$_} //= $default{$_} for keys %default;

        $conf;
    };
}

sub _config ($self, $name) {
    return $self->{opts}{$name}   if exists $self->{opts}{$name};
    return $self->{config}{$name} if exists $self->{config}{$name};
    return undef;
}

#-----------------------------

# TODO: split into a role

use Log::Handler;
use List::Util qw/pairs/;

our $LOGGER;

sub _log ($self, $level, $message, @args) {
    return unless $LOGGER;
    if (@args) {
        $message = sprintf $message, @args;
    }
    $LOGGER->log($level => $message);
}

sub setup_logger ($self, @args) {
    if (defined $args[0] && !$args[0]) {
        $LOGGER = undef;
    } else {
        if (WWW::CPANTS->is_testing) {
            $LOGGER = sub ($level, $message) {
                push @{ $self->{logs}{$level} //= [] }, $message;
            };
        } else {
            my %opts = @args == 1 ? !ref $args[0] ? {} : %{ $args[0] } : @args;
            $LOGGER = Log::Handler->new(@{ $self->_logger_config(%opts) });
        }
    }
}

sub _logger_config ($self, %opts) {
    my @default_config = map { (
        file => {
            filename => "LOGDIR/${_}_%d{yyyyMM}.log",
            minlevel => $_,
            maxlevel => $_,
        },
    ) } qw/alert error warning notice/;

    if ($self->_mode_is('development') or $opts{verbose}) {
        push @default_config, (
            screen => {
                log_to   => 'STDERR',
                minlevel => 'emergency',
                maxlevel => 'info',
            },
        );
    }

    if ($opts{debug}) {
        push @default_config, (
            screen => {
                log_to   => 'STDERR',
                minlevel => 'debug',
                maxlevel => 'debug',
            },
            file => {
                filename => 'LOGDIR/debug_%d{yyyyMMdd_HH}.log',
                minlevel => 'debug',
                maxlevel => 'debug',
            },
        );
    }
    push @default_config, @{ $self->_config('logger') // [] };

    my @config;
    my $log_dir = dir('log'); $log_dir->mkpath;
    for (pairs @default_config) {
        my ($class, $conf) = @$_;
        if ($class eq 'file') {
            if ($conf->{filename} =~ /LOGDIR/) {
                $conf->{filename} =~ s/LOGDIR/$log_dir/;
            }
            if ($conf->{filename} =~ /%d\{/) {
                $class = 'Log::Handler::Output::File::Stamper';
                $conf->{timeformat} //= '%Y-%m-%d %H:%M:%S';
            }
        } elsif ($class eq 'email_sender') {
            $class = 'Log::Handler::Output::Email::Sender';
            if (my $email_from = $self->_config('email_from')) {
                $conf->{from} //= $email_from;
            }
            if (my $email_to = $self->_config('email_to')) {
                $conf->{to} //= $email_to;
            }
        }
        $conf->{message_layout} //= '%T %L %m';
        $conf->{timeformat}     //= '%Y-%m-%d %H:%M:%S';
        push @config, $class, $conf;
    }
    \@config;
}

sub DESTROY ($self) {
    $LOGGER && $LOGGER->flush;
}

1;
