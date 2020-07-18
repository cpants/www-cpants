package WWW::CPANTS::Bin::Task::Analyze::UpdateProvides;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use parent 'WWW::CPANTS::Bin::Task';

my $SpecialFilesRe = join '|', map({ "\\b" . quotemeta($_) . '$' } qw/
        MANIFEST
        META.yml
        META.json
        Makefile.PL
        Build.PL
        dist.ini
        cpanfile
        /),
    '^(?:Changes|ChangeLog)', '^README';

sub run ($self, @args) {
    # FIXME
}

sub setup ($self, $db = undef) {
    $self->{db}    = $db //= $self->db;
    $self->{table} = $db->table('Provides');
    $self;
}

sub update ($self, $uid, $stash) {
    return unless exists $stash->{versions};
    my $cpan = $self->cpan;

    my $pause_id   = $stash->{author};
    my $versions   = $stash->{versions};
    my $abstract   = $stash->{abstracts_in_pod} // {};
    my %module_map = map { $_->{module} => 1 } @{ $stash->{modules} // [] };

    my %map;
    for my $file (keys %$versions) {
        my $module_versions = $versions->{$file};
        for my $module (keys %$module_versions) {
            my $version = $module_versions->{$module};
            $version = undef if $version eq 'undef';
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
        if (!$cpan->can_upload($pause_id, $module_name)) {
            $unauthorized{$module_name} = 1;
        }
    }
    if (%unauthorized) {
        $stash->{kwalitee}{no_unauthorized_packages} = 0;
        $stash->{error}{no_unauthorized_packages}    = [sort keys %unauthorized];
    } else {
        $stash->{kwalitee}{no_unauthorized_packages} = 1;
    }

    my @special_files = grep /$SpecialFilesRe/, @{ $stash->{files_array} // [] };

    $self->{table}->update_provides(
        $uid,
        $pause_id,
        encode_json(\@modules),
        encode_json(\@provides),
        encode_json(\@special_files),
        %unauthorized ? encode_json([sort keys %unauthorized]) : undef,
    );
}

1;
