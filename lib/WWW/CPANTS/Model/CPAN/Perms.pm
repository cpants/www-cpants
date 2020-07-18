package WWW::CPANTS::Model::CPAN::Perms;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;

has 'path'  => 'modules/06perms.txt';
has 'perms' => \&_build_perms;

with qw/WWW::CPANTS::Role::CPAN::Index/;

sub _build_perms ($self) {
    my $file = $self->fetch;
    my $fh   = $file->openr;
    my %perms;
    my $seen_header;
    while (<$fh>) {
        chomp;
        if (!$seen_header) {
            if (/^$/) {
                $seen_header = 1;
            }
            next;
        }

        my ($module, $pause_id, $type) = split /,/;
        if (!$module or !$pause_id or !$type) {    ## Broken for whatever reasons
            $self->log(warn => "06perms is broken");
            close $fh;
            unlink $self->file;
            return $self->_build_perms;
        }
        $perms{ lc $module }{ uc $pause_id } = {
            module   => $module,
            pause_id => $pause_id,
            type     => $type,
        };
    }
    \%perms;
}

sub list ($self) {
    my @rows = map { values %$_ } values $self->perms->%*;
    \@rows;
}

sub can_upload ($self, $pause_id, $module) {
    $pause_id = uc $pause_id;
    $module   = lc $module;

    return 1 if !exists $self->perms->{$module};
    return 1 if exists $self->perms->{$module}{$pause_id};
    return;
}

sub preload ($self) { $self->perms }

1;
