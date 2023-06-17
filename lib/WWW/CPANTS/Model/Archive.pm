package WWW::CPANTS::Model::Archive;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use Archive::Any::Lite;
use File::Copy::Recursive qw/rcopy/;
use Path::Tiny            ();
use WWW::CPANTS::Model::TempDir;
use WWW::CPANTS::Util::Distname;
use Syntax::Keyword::Try;

with qw/WWW::CPANTS::Role::Logger/;

has 'file'    => \&_file_is_required;
has 'stash'   => \&_build_stash;
has 'tmpdir'  => \&_build_tmpdir;
has 'tmpfile' => \&_build_tmpfile;
has 'pid'     => sub ($self) { $$ };
has 'distdir';

sub _build_stash ($self) {
    my $file  = $self->file;
    my $info  = valid_distinfo($file) // {};
    my %stash = (
        dist      => $info->{name},
        path      => $info->{path},
        vname     => $info->{distvname},
        extension => $info->{extension},
        version   => $info->{version},
        author    => $info->{author},
        maturity  => $info->{maturity},
    );
    if (-f $file) {
        $stash{released_epoch} = $file->stat->mtime;
        $stash{size_packed}    = -s $file;
    }
    \%stash;
}

sub _file_is_required ($self) {
    Carp::confess "file is required";
}

sub _build_tmpdir ($self) {
    WWW::CPANTS::Model::TempDir->new(root => WWW::CPANTS->instance->root->child("tmp/analyze/$$"));
}

sub _build_tmpfile ($self) {
    try {
        return $self->file->copy($self->tmpdir->path_str);
    } catch {
        my $error = $@;
        $self->log(alert => $error);
        $self->stash->{error}{cpants} = $error;
        $self->stash->{extractable} = 0;
        return;
    }
}

sub path ($self) {
    $self->stash->{path};
}

sub should_be_ignored ($self) {
    my $file = $self->file;
    if (!-f $file) {
        $self->log(warn => "$file is not a file");
        return 1;
    }
    return 1 if $self->stash->{perl6};    # ignore silently

    my $dist = $self->stash->{dist};

    if (!defined $dist) {
        $self->log(warn => "$file seems not a CPAN distribution");
        return 1;
    }
    return 1 if $dist =~ /^(?:perl|perl_debug|parrot|Rakudo\-Star|kurila)$/;
    return 1 if $dist =~ /^SiePerl\-5\./;
    return 1 if $dist =~ /^perl[-]?5\./;
    return 1 if $dist =~ /^Perl6-Pugs/;
    return 1 if $dist =~ /^p54rc/;

    return;
}

sub has_perl_stuff ($self) {
    !exists $self->stash->{has_no_perl_stuff} ? 1 : 0;
}

sub check_perl_stuff ($self) {
    for (@{ $self->stash->{files_array} // [] }) {
        return 1 if /\.(?:pm|PL)$/;
        return 1 if /\bMETA\.(?:yml|json)$/;
    }
    $self->stash->{has_no_perl_stuff} = 1;
    return;
}

sub extract ($self) {
    my $tmpfile = $self->tmpfile or return;
    my $tmpdir  = $self->tmpdir->path_str;

    my $archive;
    my @warnings;
    my @link_errors;
    my @pax_headers;
    try {
        local $Archive::Zip::ErrorHandler = sub { die @_ };
        local $SIG{__WARN__} = sub {
            if ($_[0] =~ /^Making (?:hard|symbolic) link from '([^']+)'/) {
                push @link_errors, $1;
                return;
            }
            if ($_[0] =~ /^Invalid header/) {
                push @warnings, $_[0];
                return;
            }
            die @_;
        };

        # NOTE
        # $Archive::Tar::CHMOD is turned off by CPAN::ParseDistribution,
        # which is nice and secure in general, but we need it to be true
        # here to check buildtool_not_executable.
        local $Archive::Tar::CHMOD = 1;
        $archive = Archive::Any::Lite->new($tmpfile) or Carp::croak "Can't extract $tmpfile";
        $archive->extract(
            $tmpdir, {
                tar_filter_cb => sub ($entry) {
                    if ($entry->name eq Archive::Tar::Constant::PAX_HEADER() or $entry->type eq 'x' or $entry->type eq 'g') {
                        push @pax_headers, $entry->name;
                        return;
                    }
                    return 1;
                }
            },
        );
    } catch {
        my $error = $@;
        $self->stash->{extractable}           = 0;
        $self->stash->{error}{extractable}    = $error;
        $self->stash->{kwalitee}{extractable} = 0;
        unlink $tmpfile;
        return;
    }

    if (@link_errors or @warnings) {
        # broken but some of the files may probably be extracted
        $self->stash->{extractable} = 0;
        my %errors;
        $errors{link_errors}                  = \@link_errors if @link_errors;
        $errors{warnings}                     = \@warnings    if @warnings;
        $self->stash->{error}{extractable}    = \%errors      if %errors;
        $self->stash->{kwalitee}{extractable} = 0;
    } else {
        $self->stash->{extractable} = 1;
    }

    if (@pax_headers) {
        $self->stash->{no_pax_headers}        = 0;
        $self->stash->{error}{no_pax_headers} = join ',', @pax_headers;
    } else {
        $self->stash->{no_pax_headers} = 1;
    }

    unlink $tmpfile;

    return 1;
}

sub is_extracted_nicely ($self) {
    my $tmpdir = $self->tmpdir;

    if (opendir my $dh, $tmpdir->path_str) {
        my @entities = grep /\w/, readdir $dh;
        if (@entities == 1) {
            $self->distdir($tmpdir->child($entities[0])->path->stringify);
            if (-d $self->distdir) {
                my $distvname = $self->stash->{vname};
                if ($distvname eq $entities[0]) {
                    $self->stash->{extracts_nicely} = 1;
                } else {
                    $distvname =~ s/\-withoutworldwritables//;
                    $distvname =~ s/\-TRIAL[0-9]*//;
                    if ($distvname eq $entities[0]) {
                        $self->stash->{extracts_nicely} = 1;
                    } else {
                        $self->stash->{extracts_nicely} = 1;
                        $self->stash->{error}{extracts_nicely} = "expected $distvname but $entities[0] is found";
                    }
                }
            } else {
                $self->distdir($tmpdir->path_str);
                $self->stash->{extracts_nicely} = 0;
                $self->stash->{error}{extracts_nicely} = "$entities[0] is not a directory";
            }
        } else {
            $self->distdir($tmpdir->path_str);
            $self->stash->{extracts_nicely}        = 0;
            $self->stash->{error}{extracts_nicely} = 'More than one top directories are found: ' . join ';', @entities;
        }
    } else {
        my $message = "Can't open $tmpdir: $!";
        $self->log(error => $message);
        $self->stash->{error}{cpants}         = $message;
        $self->stash->{extractable}           = 0;
        $self->stash->{kwalitee}{extractable} = 0;
        return;
    }
    return 1;
}

# for compatibility
sub d    ($self) { $self->stash }
sub dist ($self) { $self->file }

1;
