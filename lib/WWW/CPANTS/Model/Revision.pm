package WWW::CPANTS::Model::Revision;

use Mojo::Base -base, -signatures;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Util::Path;
use Digest::MD5 qw/md5_hex/;
use Parse::PMFile;

# external modules that may affect analysis
our @ModulesToCheck = qw(
    Archive::Tar
    Archive::Zip
    CPAN::Audit
    CPAN::Meta
    CPAN::Meta::Requirements
    ExtUtils::Manifest
    Module::CoreList
    Module::Signature
    Parse::Distname
    Parse::PMFile
    Parse::LocalDistribution
    Perl::PrereqScanner::NotQuiteLite
    Pod::Simple::Checker
    Software::License
    version
);

has 'file' => \&_build_file;
has 'data' => \&_build_data;

sub _build_file ($self) { cpants_path("etc/revision.json") }

sub _build_data ($self) {
    return {} unless -f $self->file;
    decode_json($self->file->slurp_utf8 // '{}');
}

sub id ($self) {
    $self->data->{_id};
}

sub load ($self) {
    my $file = $self->file;
    my $data = -f $file ? decode_json($file->slurp_utf8) : {};
    $self->data($data);
}

sub save ($self) {
    my $file = $self->file;
    $file->parent->mkpath;
    $self->file->spew_utf8(encode_pretty_json($self->data));
    $self->data;
}

sub check ($self) {
    my $old = $self->data // {};
    my $new = {};
    $new->{versions} = $self->_get_module_versions;
    $new->{digests}  = $self->_get_module_digests;
    $new->{_id}      = $old->{_id} //= 0;

    my $diff = json_diff($old, $new) or return;

    $new->{_id}++;
    $self->data($new);

    return $diff;
}

sub _get_module_versions ($self) {
    local $Parse::PMFile::ALLOW_DEV_VERSION = 1;
    my %versions;
    for my $module (@ModulesToCheck) {
        my $path = $module =~ s!::!/!gr;
        for my $inc (@INC) {
            my $file = "$inc/$path.pm";
            next unless -e $file;
            my $info = Parse::PMFile->new->parse($file);
            $info->{$module} or next;
            $versions{$module} = $info->{$module}{version} . "";
            last;
        }
    }
    \%versions;
}

sub _get_module_digests ($self) {
    my %digests;
    for my $dir (cpants_app_path("extlib")->children) {
        next unless $dir =~ /Module\-CPANTS\-/;
        my $iter = $dir->child("lib/Module/CPANTS")->iterator({
            recurse         => 1,
            follow_symlinks => 0,
        });
        while (my $file = $iter->()) {
            next unless $file =~ /\.pm$/;
            my $path = $file =~ s|^.+/lib/||r;
            my $body = $file->slurp;
            $body =~ s/__END__.+$//s;    # ignore pod
            $digests{$path} = md5_hex($body);
        }
    }
    \%digests;
}

1;
