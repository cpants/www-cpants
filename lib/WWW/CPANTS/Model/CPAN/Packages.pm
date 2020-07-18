package WWW::CPANTS::Model::CPAN::Packages;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use Parse::Distname qw/parse_distname/;
use WWW::CPANTS::Util::PathUid;

has 'path'     => 'modules/02packages.details.txt';
has 'packages' => \&_build_packages;

with qw/WWW::CPANTS::Role::CPAN::Index/;

sub _build_packages ($self) {
    ## 02packages should be fetched only while testing
    ## to avoid minicpan inconsistency
    my $file = WWW::CPANTS->instance->is_testing ? $self->fetch : $self->unzipped_file;
    Carp::croak "no 02packages" unless -f $file;

    my $fh = $file->openr;
    my %packages;
    my $seen_header;
    while (<$fh>) {
        chomp;
        if (!$seen_header) {
            if (/^$/) {
                $seen_header = 1;
            }
            next;
        }
        next if /\A\s*\z/;
        my ($module, $version, $path) = split /\s+/;
        if (!$module or !defined $version or !$path) {    ## Broken for whatever reasons
            $self->log(warn => "02packages is broken");
            close $fh;
            unlink $self->file;
            return $self->_build_packages;
        }
        my $info = parse_distname($path);
        next unless $info->{name};
        my $uid = path_uid($info->{cpan_path}) or next;
        $packages{ lc $module } = {
            module  => $module,
            version => $version,
            path    => $info->{cpan_path},
            uid     => $uid,
            dist    => $info->{name},
        };
    }
    \%packages;
}

sub find ($self, $module) {
    $self->packages->{ lc $module };
}

sub list ($self) {
    my @rows = values $self->packages->%*;
    \@rows;
}

sub distname ($self, $module) {
    my $info = $self->find($module) or return;
    $info->{dist};
}

sub indexed_path_for ($self, $module) {
    my $info = $self->find($module) or return;
    $info->{path};
}

sub preload ($self) { $self->packages }

1;
