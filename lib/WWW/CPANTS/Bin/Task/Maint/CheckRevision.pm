package WWW::CPANTS::Bin::Task::Maint::CheckRevision;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use parent 'WWW::CPANTS::Bin::Task';
use Module::Version qw/get_version/;

my @Packages = qw/
    CPAN::DistnameInfo
    CPAN::Meta
    CPAN::Meta::Requirements
    Module::CoreList
    Module::ExtractUse
    Module::Signature
    Parse::PMFile
    Parse::LocalDistribution
    Software::License
    version
    /;

sub run ($self, @args) {
    my $file = json_file("etc/revision.json");
    my $old  = $file->exists ? $file->slurp_utf8 : '{}';
    my $json = decode_relaxed_json($old);

    my %new;
    for my $package (@Packages) {
        $new{versions}{$package} = get_version($package) . "";
    }

    if (0) {
        my $iter = app_dir("lib/WWW/CPANTS/Bin/Task")->iterator({ recurse => 0, follow_symlinks => 0 });
        while (my $file = $iter->()) {
            next if $file->is_dir;
            my $path = $file->stringify;
            next unless $path =~ /\.pm$/;
            $path =~ s|^.+lib/||;
            my $body = $file->slurp;
            $body =~ s/__END__.+$//s;    # ignore pod
            $new{md5}{$path} = md5($body);
        }
    }

    for my $extdir (app_dir("extlib")->children) {
        my $iter = $extdir->child("lib")->iterator({ recurse => 1, follow_symlinks => 0 });
        while (my $file = $iter->()) {
            next if $file->is_dir;
            my $path = $file->stringify;
            next unless $path =~ /\.pm$/;
            $path =~ s|^.+lib/||;
            $new{md5}{$path} = md5($file->slurp);
        }
    }
    $new{_id} = $json->{_id};

    if (diff_json($old, \%new)) {
        $new{_id}++;
        $file->spew_utf8(encode_json(\%new));
    }
}

1;
