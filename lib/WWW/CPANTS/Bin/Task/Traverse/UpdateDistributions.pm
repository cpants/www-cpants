package WWW::CPANTS::Bin::Task::Traverse::UpdateDistributions;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use parent 'WWW::CPANTS::Bin::Task';

sub run ($self, @args) {
    # FIXME
}

sub setup ($self) {
    my $table = $self->db->table('Distributions');
    my $iter  = $table->iterate_name_and_uids;

    my %dists;
    while (my $dist = $iter->next) {
        my @uids = @{ decode_json($dist->{uids}) // [] };
        my $first_uid = @uids ? $uids[-1]{uid} : undef;
        my %uid_map = map { $_->{uid} => $_ } @uids;
        $dists{ $dist->{name} } = {
            id                => $dist->{id},
            uids              => \%uid_map,
            latest_stable_uid => $dist->{latest_stable_uid},
            latest_dev_uid    => $dist->{latest_dev_uid},
            first_uid         => $first_uid,
        };
    }
    $self->{dists} = \%dists;

    $self;
}

sub add_dist_uid ($self, $dist, $uid, $info) {
    $self->{dists}{$dist}{uids}{$uid} = $info;
    $self->{dists}{$dist}{_updated} = 1;
}

sub mark_backpan ($self, $dist, $uid) {
    my $prev = $self->{dists}{$dist}{uids}{$uid}{cpan};
    $self->{dists}{$dist}{uids}{$uid}{cpan} = 0;
    if ($prev) {
        $self->{dists}{$dist}{_updated} = 1;
        push @{ $self->{new_backpan} //= [] }, $uid;
    }
}

sub mark_cpan ($self, $dist, $uid) {
    my $prev = $self->{dists}{$dist}{uids}{$uid}{cpan};
    $self->{dists}{$dist}{uids}{$uid}{cpan} = 1;
    if (!$prev) {
        $self->{dists}{$dist}{_updated} = 1;
        push @{ $self->{new_cpan} //= [] }, $uid;
    }
}

sub update ($self) {
    my $dists = $self->{dists};

    log(info => "updating distributions");

    my $db            = $self->db;
    my $uploads       = $db->table('Uploads');
    my $kwalitee      = $db->table('Kwalitee');
    my $distributions = $db->table('Distributions');

    for my $name (keys %$dists) {
        my $dist = $dists->{$name};
        next if !$dist->{_updated} && $self->option('force');
        my ($first_uid, $latest_stable_uid, $latest_dev_uid, $latest_uid);
        my $uids        = $dist->{uids} // {};
        my @sorted_uids = sort { ($uids->{$a}{released} // 0) <=> ($uids->{$b}{released} // 0) } grep { $uids->{$_}{uid} } keys %$uids;
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
        $distributions->update_uids({
            id                => $dist->{id},
            name              => $name,
            uids              => encode_json([map { $uids->{$_} } reverse @sorted_uids]),
            first_uid         => $first_uid,
            latest_uid        => $latest_uid,
            latest_dev_uid    => $latest_dev_uid,
            latest_stable_uid => $latest_stable_uid,
            first_released_at => $uids->{$first_uid}{released},
            last_released_at  => $uids->{$latest_uid}{released},
            last_released_by  => $uids->{$latest_uid}{author},
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
    }

    log(info => "updated distributions");
}

1;
