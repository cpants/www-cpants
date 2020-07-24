package WWW::CPANTS::Bin::Task::Maint::CheckVersions;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use Module::Version qw/get_version/;
use MetaCPAN::Client;
use HTTP::Tiny::Mech;
use WWW::Mechanize::Cached;
use Cache::FileCache;
use Path::Tiny;

our @OPTIONS = (
    'check_cpanfile|check-cpanfile',
    'update',
);

has 'cache_root'   => \&_build_cache_root;
has 'client'       => \&_build_client;
has 'cpanfile'     => \&_build_cpanfile;
has 'requirements' => \&_build_requirements;

sub _build_cache_root ($self) {
    WWW::CPANTS->instance->app_root->child("tmp/cache");
}

sub _build_cpanfile ($self) {
    WWW::CPANTS->instance->app_root->child("cpanfile");
}

sub _build_requirements ($self) {
    require Module::CPANfile;
    my $cpanfile = Module::CPANfile->load($self->cpanfile);
    my @features = map { $_->identifier } $cpanfile->features;
    if ($^O eq 'MSWin32') {
        @features = grep !/production/, @features;
    }
    $cpanfile->prereqs_with(@features)->merged_requirements;
}

sub _build_client ($self) {
    MetaCPAN::Client->new(
        ua => HTTP::Tiny::Mech->new(
            mechua => WWW::Mechanize::Cached->new(
                cache => Cache::FileCache->new({
                    namespace          => 'MetaCPAN',
                    default_expires_in => 86400,
                    cache_root         => $self->cache_root,
                }),
            ),
        ),
    );
}

my @DefaultModules = qw(
    CPAN::Audit
    CPAN::Meta
    CPAN::Meta::Requirements
    Module::CoreList
    Module::Signature
    Parse::PMFile
    Parse::LocalDistribution
    Perl::PrereqScanner::NotQuiteLite
    Software::License
    version
);

sub run ($self, @args) {
    return if WWW::CPANTS->is_testing;

    my @modules;
    if ($self->check_cpanfile) {
        @modules = $self->requirements->required_modules;
    } else {
        @modules = @args ? @args : @DefaultModules;
    }

    my @modules_to_update;
    for my $module (@modules) {
        next if $module =~ /^\-/;    # maybe a bogus option
        next if $module eq 'perl';
        my $installed = get_version($module) // '';
        my $res       = $self->client->module($module, { fields => 'version' });
        my $version   = $res->version // '';
        if (!$self->requirements->accepts_module($module => $version)) {
            $self->log(notice => "$module $version is ignored by cpanfile");
            next;
        }
        if ($version ne $installed) {
            $self->log(notice => "$module: newer version is found: $version (installed: $installed)");
            push @modules_to_update, $module;
        } else {
            $self->log(info => "$module: $version (latest)");
        }
    }

    if ($self->update and @modules_to_update) {
        $self->update_modules(@modules_to_update);
    }
}

sub update_modules ($self, @modules) {
    require Menlo::CLI::Compat;
    my $menlo = Menlo::CLI::Compat->new;
    $menlo->parse_options(@modules);
    $menlo->run;
}

1;
