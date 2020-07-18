package WWW::CPANTS::Bin::Task::Traverse;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::Distname;

our @READ = qw/Authors Uploads/;

has 'update_dists'       => \&_build_update_dists;
has 'update_author_json' => \&_build_update_author_json;
has 'register_new'       => \&_build_register_new;
has 'cpan_status'        => \&_build_cpan_status;

sub _build_update_dists ($self) {
    $self->subtask('Traverse::UpdateDistributions');
}

sub _build_update_author_json ($self) {
    $self->subtask('Traverse::UpdateAuthorJson');
}

sub _build_register_new ($self) {
    $self->subtask('RegisterNew');
}

sub _build_cpan_status ($self) {
    $self->subtask('Traverse::UpdateCPANStatus');
}

sub subtasks ($self) {
    [
        $self->update_dists,
        $self->update_author_json,
        $self->register_new,
        $self->cpan_status,
    ];
}

sub run ($self, @args) {
    my $db = $self->db;

    my $pause_ids =
        @args
        ? \@args
        : $db->table('Authors')->select_all_pause_ids_ordered_by_cpan_dists;

    if (!@$pause_ids) {
        $self->log(warn => "No pause_ids");
        return;
    }

    my $needs_backpan = $db->table('Uploads')->exists ? 0 : 1;
    $needs_backpan = 1 if $self->ctx->force or $self->ctx->all;

    $self->traverse_backpan($pause_ids) if $needs_backpan;
    $self->traverse_cpan($pause_ids);

    $self->update_dists->finalize;
}

sub traverse_cpan ($self, $pause_ids) {
    $self->log(info => 'traversing CPAN');
    $self->traverse($self->cpan, 1, $pause_ids);
}

sub traverse_backpan ($self, $pause_ids) {
    $self->log(info => 'traversing BackPAN');
    $self->traverse($self->backpan, 0, $pause_ids);
}

sub traverse ($self, $cpan, $is_cpan, $pause_ids) {
    my %seen;
    my $done = 0;
    $self->timer->total(scalar @$pause_ids);
    for my $pause_id (@$pause_ids) {
        if ($done++ and !($done % 100)) {
            $self->timer->show_progress($done);
        }
        my $iter = $cpan->author_dir_iterator($pause_id) or next;

        my $whois = $self->cpan->whois->authors->{$pause_id};
        next if $whois->{deleted} or ($whois->{nologin} && !$whois->{system});

        $self->log(info => "$pause_id");

        if ($is_cpan) {
            $self->cpan_status->load_uids_for($pause_id);
        }

        my @dists;
        my $needs_update;
        while (my $file = $iter->()) {
            next if -d $file;

            my $path = $self->_relpath($file->stringify);

            if ($is_cpan and $path =~ m!/author(?:\-\d+)?\.json$!) {
                $self->update_author_json->update($pause_id, $file);
                next;
            }

            my $dist = valid_distinfo($path) or next;
            my $uid  = $dist->{uid};

            if ($seen{$uid}++) {
                $self->log(error => "Duplicated uid: $uid ($path)");
                next;
            }

            if ($self->cpan_status->has_uid($uid)) {
                $self->cpan_status->mark($uid);
                next unless $self->ctx->force;
            } elsif ($is_cpan) {
                $self->cpan_status->mark($uid);
                $needs_update = 1;
            }

            $dist->{cpan}     = $is_cpan;
            $dist->{released} = $file->stat->mtime;

            push @dists, $dist;

            $self->update_dists->mark($dist, $is_cpan);
        }

        if ($is_cpan) {
            $self->cpan_status->mark_backpan;
            if ($needs_update or $self->ctx->force) {
                $self->cpan_status->mark_cpan;
            }
        }

        unless (@dists) {
            # $self->log(debug => "$pause_id hasn't released anything");
            next;
        }

        my $registered = $self->register_new->register_if_new(\@dists) or next;
        $self->log(info => "inserted $registered distributions for $pause_id");
    }
}

sub _relpath ($self, $fullpath) {
    # $file->relative is rather slow
    # NB. there may be another authors/id/ part in the middle (BILLW/authors/id/...)
    $fullpath =~ s|\\|/|g if $^O eq 'MSWin32';
    my ($path) = $fullpath =~ m|^.*?authors/id/(.+)$|;
    $path;
}

1;
