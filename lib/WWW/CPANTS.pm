package WWW::CPANTS;

use 5.028;
use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use List::Util 1.29 qw/pairs/;
use Path::Tiny   ();
use Data::Dump   ();
use Data::Binary ();    ## workaround for a Perl 5.30 regression

our $VERSION = '5.00';

our @OPTIONS = (
    'debug',
    ['quiet|q'                => \&_build_quiet],
    ['cpan_path|cpan=s'       => \&_build_cpan_path],
    ['backpan_path|backpan=s' => \&_build_backpan_path],
);

with qw(
    MooX::Singleton
    WWW::CPANTS::Role::Options
);

has 'app_root'   => \&_build_app_root;
has 'root'       => \&_build_root;
has 'logger'     => \&_build_logger;
has 'config'     => \&_build_config;
has 'config_pl'  => \&_build_config_pl;
has 'use_extlib' => \&_build_use_extlib;

sub _build_quiet ($self) {
    return !$ENV{HARNESS_IS_VERBOSE} if $self->is_testing;
    return;
}

sub _build_use_extlib ($self) {
    my $app_root = $self->app_root;
    require lib;
    lib->import(glob "$app_root/extlib/*/lib");
    1;
}

sub is_under_maintenance ($self) {
    $self->root->child('__maintenance__')->exists ? 1 : 0;
}

sub is_testing ($self) {
    $ENV{HARNESS_ACTIVE} ? 1 : 0;
}

sub _build_app_root ($self) {
    Path::Tiny::path(__FILE__)->parent->parent->parent->realpath;
}

sub _build_root ($self) {
    return $self->app_root unless $self->is_testing;

    my $tmp_root = $self->app_root->child("tmp/test");
    $tmp_root->mkpath;

    require WWW::CPANTS::Model::TempDir;
    WWW::CPANTS::Model::TempDir->new(root => $tmp_root);
}

sub _build_config_pl ($self) {
    $self->root->child("etc/config.pl");
}

sub _build_config ($self) {
    my %config;
    my $file = $self->config_pl;
    if (-f $file) {
        %config = %{ do "$file" };
    }
    \%config;
}

sub _build_cpan_path ($self) {
    __build_mirror_path($self, 'cpan');
}

sub _build_backpan_path ($self) {
    __build_mirror_path($self, 'backpan');
}

sub __build_mirror_path ($self, $type) {
    return $self->root->child($type) if $self->is_testing;

    if (my $path = $self->config->{ $type . "_path" }) {
        return $path;
    }
    return "$ENV{HOME}/$type";
}

sub _build_logger ($self) {
    my @config  = @{ $self->config->{logger} // [] };
    my $log_dir = $self->config->{log_dir} // $self->root->child("log");
    $log_dir->mkpath unless -d $log_dir;

    $self->use_extlib;

    # default loggers
    push @config, map { (
        file => {
            filename => "LOGDIR/${_}_%d{yyyyMM}.log",
            minlevel => $_,
            maxlevel => $_,
        },
    ) } qw/alert error warning notice/;

    if (!$self->quiet) {
        push @config, (
            screen => {
                log_to   => 'STDERR',
                minlevel => 'emergency',
                maxlevel => 'info',
            },
        );
    }

    if ($self->debug or ($self->is_testing && $ENV{HARNESS_IS_VERBOSE})) {
        push @config, (
            screen => {
                log_to   => 'STDERR',
                minlevel => 'debug',
                maxlevel => 'debug',
            },
            file => {
                filename => "LOGDIR/debug_%d{yyyyMMdd_HH}.log",
                minlevel => 'info',
                maxlevel => 'debug',
            },
        );
    }

    my @handler_config;
    for my $pair (pairs @config) {
        my ($class, $conf) = @$pair;
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
            if (my $email_from = $self->config->{email_from}) {
                $conf->{from} //= $email_from;
            }
            if (my $email_to = $self->config->{email_to}) {
                $conf->{to} //= $email_to;
            }
        } elsif ($class eq 'slack') {
            $class = 'Log::Handler::Output::Slack';
        }
        $conf->{message_layout} //= '%T %L %m';
        $conf->{timeformat}     //= '%Y-%m-%d %H:%M:%S';
        push @handler_config, $class, $conf;
    }

    require Log::Handler;
    Log::Handler->new(@handler_config);
}

sub merge_config ($self, $config) {
    require Hash::Merge::Simple;
    $self->config(Hash::Merge::Simple::merge($self->config, $config));
}

1;

__END__

=encoding utf-8

=head1 NAME

WWW::CPANTS - new CPANTS frontend/backend

=head1 DESCRIPTION

This is a proof of concept for the CPANTS website refactoring from scratch. Everything is discarded except for Module::CPANTS::Kwalitee and its components (and some of the Site templates for now).

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012- by Kenichi Ishigaki.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
