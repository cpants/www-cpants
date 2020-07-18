package WWW::CPANTS::Bin::Task::Maint::CheckRevision;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Model::Revision;
use version;

has 'revision' => \&_build_revision;

sub _build_revision ($self) {
    WWW::CPANTS::Model::Revision->new;
}

sub run ($self, @args) {
    my $diff = $self->revision->check;
    if ($diff) {
        $self->log(notice => $diff);
        $self->revision->save;
    }

    my $packages = $self->cpan->packages;
    my $versions = $self->revision->data->{versions};
    for my $module (sort keys %$versions) {
        next if $module eq 'Archive::Zip';    ## Recent versions are broken
        my $installed = $versions->{$module};
        my $latest    = $packages->find($module)->{version};
        if (version->parse($latest) > version->parse($installed)) {
            $self->log(notice => "$module: $latest (installed: $installed)");
        }
    }
}

1;
