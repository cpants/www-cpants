package WWW::CPANTS::Bin::Task::Traverse::UpdateDistributions;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::JSON;

our @READ  = qw/Uploads Distributions/;
our @WRITE = qw/Distributions Kwalitee Uploads/;

has 'dists' => \&_build_dists;

sub _build_dists ($self) {
    my $table = $self->db->table('Distributions');
    my $iter  = $table->iterate_name_and_uids;

    my %dists;
    while (my $dist = $iter->next) {
        my @uids      = @{ decode_json($dist->{uids}) // [] };
        my $first_uid = @uids ? $uids[-1]{uid} : undef;
        my %uid_map   = map { $_->{uid} => $_ } @uids;
        $dists{ $dist->{name} } = {
            id                => $dist->{id},
            uids              => \%uid_map,
            latest_stable_uid => $dist->{latest_stable_uid},
            latest_dev_uid    => $dist->{latest_dev_uid},
            first_uid         => $first_uid,
        };
    }
    \%dists;
}

sub run ($self, @args) {
    my $cpan     = $self->ctx->cpan;
    my $iterator = $self->db->table('Uploads')->iterate;
    while (my $row = $iterator->next) {
        $self->mark($row, $cpan->distribution($row->{path})->exists ? 1 : 0);
    }
    $self->finalize;
}

sub mark ($self, $dist, $is_cpan) {
    my ($name, $uid) = @$dist{qw/name uid/};
    return unless defined $name and $uid;

    my $dists   = $self->dists;
    my $current = $dists->{$name}{uids}{$uid};
    if (!$current) {
        $dists->{$name}{uids}{$uid} = { %$dist{qw/uid author version version_number released cpan stable/} };
        $dists->{$name}{_updated} = 1;
        return;
    }
    if ($current->{cpan} != $is_cpan) {
        $current->{cpan} = $is_cpan;
        $dists->{$name}{_updated} = 1;
    }
}

sub finalize ($self) {
    my $dists = $self->dists;

    $self->log(info => "updating distributions");

    my $db            = $self->db;
    my $uploads       = $db->table('Uploads');
    my $kwalitee      = $db->table('Kwalitee');
    my $distributions = $db->table('Distributions');

    for my $name (keys %$dists) {
        my $dist = $dists->{$name};
        next if !$dist->{_updated} && !$self->force;
        my ($first_uid, $latest_stable_uid, $latest_dev_uid, $latest_uid);
        my $uids        = $dist->{uids} // {};
        my @sorted_uids = sort { ($uids->{$a}{released} // 0) <=> ($uids->{$b}{released} // 0) } grep { $uids->{$_}{uid} } keys %$uids;
        unless (@sorted_uids) {
            $self->log(warn => "$name has no uids");
            next;
        }
        for my $uid (@sorted_uids) {
            # FIXME: check unauthorized releases
            $first_uid //= $uid;
            if ($uids->{$uid}{stable}) {
                $latest_stable_uid = $latest_uid = $uid;
                $latest_dev_uid    = undef;
            } else {
                $latest_dev_uid = $latest_uid = $uid;
            }
        }
        my $txn = $db->handle->txn;
        $distributions->update_uids({
            id                => $dist->{id},
            name              => $name,
            uids              => encode_json([map { $uids->{$_} } reverse @sorted_uids]),
            first_uid         => $first_uid,
            latest_uid        => $latest_uid,
            latest_dev_uid    => $latest_dev_uid,
            latest_stable_uid => $latest_stable_uid,
            first_release_at  => $uids->{$first_uid}{released},
            last_release_at   => $uids->{$latest_uid}{released},
            last_release_by   => $uids->{$latest_uid}{author},
        });

        if (($first_uid // '') ne ($dist->{first_uid} // '')) {
            if ($dist->{first_uid}) {
                $uploads->unmark_first($dist->{first_uid});
            }
            if ($first_uid) {
                $uploads->mark_first($first_uid);
            }
        }

        if (($latest_stable_uid // '') ne ($dist->{latest_stable_uid} // '')) {
            if ($dist->{latest_stable_uid}) {
                $uploads->unmark_latest($dist->{latest_stable_uid});
                $kwalitee->unmark_latest($dist->{latest_stable_uid});
            }
            if ($latest_stable_uid) {
                $uploads->mark_latest($latest_stable_uid);
                $kwalitee->mark_latest($latest_stable_uid);
            }
        }
        if (($latest_dev_uid // '') ne ($dist->{latest_dev_uid} // '')) {
            if ($dist->{latest_dev_uid}) {
                $uploads->unmark_latest($dist->{latest_dev_uid});
                $kwalitee->unmark_latest($dist->{latest_dev_uid});
            }
            if ($latest_dev_uid) {
                $uploads->mark_latest($latest_dev_uid);
                $kwalitee->mark_latest($latest_dev_uid);
            }
        }
        $txn->commit if $txn;
    }

    $self->log(info => "updated distributions");
}

1;
