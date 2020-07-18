package WWW::CPANTS::Model::TableGuard;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use WWW::CPANTS::Util::Path;

has 'dir' => \&_build_dir;
has 'pid' => sub ($self) { $$ };
has 'files';

with qw/WWW::CPANTS::Role::Logger/;

sub _build_dir ($self) {
    my $dir = cpants_path("tmp/table_guard");
    $dir->mkpath unless -d $dir;
    $dir;
}

sub check ($self, @tables) {
    my @files;
    for my $table (@tables) {
        my $file = $self->dir->child($table);
        if (-f $file) {
            my $pid = $file->slurp;
            $self->log(warn => "Another task ($pid) is using $table");
            $_->remove for @files;
            return;
        }
        $file->spew($$);
        push @files, $file;
    }
    $self->files(\@files);
    return 1;
}

sub DESTROY ($self) {
    my $files = $self->files or return;
    for my $file (@$files) {
        next unless -f $file;
        my $pid = $file->slurp;
        $file->remove if $pid eq $self->pid;
    }
}

1;
