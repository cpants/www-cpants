package WWW::CPANTS::Role::CPAN::Index;

use Mojo::Base -role, -signatures;
use LWP::UserAgent;
use IO::Uncompress::Gunzip;

has 'root'   => \&_root_is_required;
has 'file'   => \&_build_file;
has 'gzpath' => \&_build_gzpath;
has 'gzfile' => \&_build_gzfile;

with qw(WWW::CPANTS::Role::Logger);

sub _root_is_required ($self) {
    Carp::confess "root is required";
}

sub _build_file ($self) {
    $self->root->child($self->path);
}

sub _build_gzpath ($self) {
    return unless $self->path =~ /\.txt$/;
    $self->path . '.gz';
}

sub _build_gzfile ($self) {
    my $gzpath = $self->gzpath or return;
    $self->root->child($gzpath);
}

sub fetch ($self) {
    my $file = $self->file;
    return $file if -f $file and $file->stat->mtime > time - 86400;

    local $SIG{INT} = sub { unlink $file };    ## remove partial index
    if ($self->gzpath) {
        my $gzfile = $self->gzfile;
        if (!-f $gzfile or $gzfile->stat->mtime < time - 86400) {
            $self->_mirror($self->gzpath => $gzfile);
        }
        $self->_gunzip($gzfile => $file);
        return $file;
    }
    $self->_mirror($self->path => $file);
    return $file;
}

sub unzipped_file ($self) {
    my $file   = $self->file;
    my $gzfile = $self->gzfile;
    if ($gzfile && -f $gzfile) {
        return $self->_gunzip($gzfile => $file);
    }
    return $file if -f $file;
    return;
}

sub _gunzip ($self, $gzfile, $file) {
    IO::Uncompress::Gunzip::gunzip("$gzfile" => "$file")
        or Carp::croak "$gzfile: $IO::Uncompress::Gunzip::GunzipError";
    $file;
}

sub _mirror ($self, $path, $file) {
    my $uri = "https://cpan.cpanauthors.org/$path";
    return if $ENV{CPANTS_API_NO_NETWORK};

    $self->log(info => "Fetching $uri to $file");
    $file->parent->mkpath unless -d $file->parent;

    my $res = LWP::UserAgent->new->mirror($uri => $file);
    Carp::croak "failed to mirror $uri: " . $res->status_line unless $res->is_success;
}

1;
