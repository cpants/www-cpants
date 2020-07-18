package WWW::CPANTS::Bin::Task::Analyze::UpdateProvides;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::JSON;

our @READ  = qw/Analysis/;
our @WRITE = qw/Provides/;

with qw/WWW::CPANTS::Role::Task::FixAnalysis/;

my @SpecialFiles = qw(
    MANIFEST
    META.yml
    META.json
    Makefile.PL
    Build.PL
    dist.ini
    cpanfile
);
my $SpecialFilesRe = join '|', (
    map({ "\\b" . quotemeta($_) . '$' } @SpecialFiles),
    '^(?:Changes|ChangeLog)',
    '^README',
);

sub update ($self, $uid, $stash) {
    return unless exists $stash->{versions};

    my $cpan = $self->ctx->cpan;

    my $pause_id   = $stash->{author};
    my $versions   = $stash->{versions};
    my $abstract   = $stash->{abstracts_in_pod} // {};
    my %module_map = map { $_->{module} => 1 } @{ $stash->{modules} // [] };

    my %map;
    for my $file (keys %$versions) {
        my $module_versions = $versions->{$file};
        for my $module (keys %$module_versions) {
            my $version = $module_versions->{$module};
            $version                = undef if $version eq 'undef';
            $map{$module}{version}  = $version;
            $map{$module}{file}     = $file;
            $map{$module}{abstract} = $abstract->{$module};
        }
    }

    my (@modules, @provides, %unauthorized);
    for my $module_name (sort keys %map) {
        if ($module_map{$module_name}) {
            my %module = (name => $module_name);
            $module{version}  = $map{$module_name}{version}  if defined $map{$module_name}{version};
            $module{abstract} = $map{$module_name}{abstract} if defined $map{$module_name}{abstract};
            push @modules, \%module;
        } else {
            push @provides, {
                name => $module_name,
                file => $map{$module_name}{file},
            };
        }
        if (!$cpan->perms->can_upload($pause_id, $module_name)) {
            $unauthorized{$module_name} = 1 unless $module_name eq 'UNIVERSAL';
        }
    }
    if (%unauthorized) {
        $stash->{kwalitee}{no_unauthorized_packages} = 0;
        $stash->{error}{no_unauthorized_packages}    = [sort keys %unauthorized];
    } else {
        $stash->{kwalitee}{no_unauthorized_packages} = 1;
    }

    return if $self->dry_run;

    my @special_files = grep /$SpecialFilesRe/, @{ $stash->{files_array} // [] };

    $self->db->table('Provides')->update_provides(
        $uid,
        $pause_id,
        encode_json(\@modules),
        encode_json(\@provides),
        encode_json(\@special_files),
        %unauthorized ? encode_json([sort keys %unauthorized]) : undef,
    );
}

1;
