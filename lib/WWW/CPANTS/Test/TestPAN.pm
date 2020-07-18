package WWW::CPANTS::Test::TestPAN;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use WWW::CPANTS;
use WWW::CPANTS::Util::Path;
use WorePAN 0.16;
use Path::Tiny            ();
use File::Copy::Recursive ();
use Test::MockTime::HiRes;    ## to avoid caching

has 'root'         => \&_build_root;
has 'cpan'         => \&_build_cpan;
has 'backpan'      => \&_build_backpan;
has 'local_mirror' => \&_build_local_mirror;
has 'pid'          => sub ($self) { $$ };
has 'created_indices';

with qw(
    WWW::CPANTS::Role::Logger
    WWW::CPANTS::Role::CPAN::Indices
    WWW::CPANTS::Role::CPAN::Path
);

sub _build_cpan ($self) {
    __build_mirror($self, WWW::CPANTS->instance->cpan_path);
}

sub _build_backpan ($self) {
    __build_mirror($self, WWW::CPANTS->instance->backpan_path);
}

sub __build_mirror ($self, $root) {
    $root = Path::Tiny::path($root) unless ref $root;
    $root->mkpath;

    WorePAN->new(
        root               => $root,
        local_mirror       => $self->local_mirror,
        use_backpan        => 1,
        no_network         => 0,
        no_indices         => 1,
        developer_releases => 1,
        cpan               => 'https://cpan.cpanauthors.org/',
        backpan            => 'https://backpan.cpanauthors.org/',
    );
}

sub _build_root ($self) {
    Path::Tiny::path(WWW::CPANTS->instance->cpan_path);
}

sub _build_local_mirror ($self) {
    my $path = cpants_app_path("tmp/local_mirror");
    $path->mkpath unless -d $path;
    $path;
}

sub local_file ($self, $path) {
    $self->local_mirror->child($path);
}

sub setup ($self, @files) {
    @files = ('I/IS/ISHIGAKI/Path-Extended-0.19.tar.gz') unless @files;
    $self->add_files(@files);
    for my $index ($self->indices->@*) {
        my $file       = $index->file;
        my $local_file = $self->local_file($index->path);
        next unless -f $local_file;
        next if $local_file->stat->mtime < time - 86400;
        _rcopy($local_file, $file);
        $self->log(debug => "copied $local_file to $file");
    }
    $self;
}

sub add_files ($self, @files) {
    for my $type (qw/cpan backpan/) {
        my $worepan = $self->$type;
        $worepan->add_files(@files);
        $worepan->update_indices;
        $self->created_indices(1);
    }
}

sub backup ($self) {
    $self->_backup_distributions;
    $self->_backup_indices;
}

sub _backup_distributions ($self) {
    my $root = $self->cpan->root;
    my $iter = $root->child('authors/id')->iterator({
        recurse         => 1,
        follow_symlinks => 0,
    });
    while (my $file = $iter->()) {
        next unless -f $file;
        my $path       = $file->relative($root);
        my $local_file = $self->local_mirror->child($path);
        next if $local_file->exists;
        _rcopy($file, $local_file);
    }
}

sub _backup_indices ($self) {
    return if $self->created_indices;
    for my $index ($self->indices->@*) {
        my $file = $index->file;
        next unless -f $file;
        my $local_file = $self->local_file($index->path);
        next if -f $local_file and $file->stat->mtime <= $local_file->stat->mtime;
        _rcopy($file, $local_file);
        $self->log(debug => "copied $file to $local_file");
    }
}

sub DESTROY ($self) {
    return unless $self->pid eq $$;
    $self->backup;
}

sub _rcopy ($source, $destination) {
    File::Copy::Recursive::rcopy($source, $destination);
    my $mtime = $source->stat->mtime;
    utime $mtime, $mtime, $destination;
}

1;
