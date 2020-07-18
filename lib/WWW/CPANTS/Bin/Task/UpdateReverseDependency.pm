package WWW::CPANTS::Bin::Task::UpdateReverseDependency;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use parent 'WWW::CPANTS::Bin::Task';

sub run ($self, @args) {
    my $db   = $self->db;
    my $cpan = $self->cpan;
    $cpan->fetch_packages_details unless $cpan->has_packages_details;
    my %packages_details;
    for my $row (@{ $cpan->list_packages_details }) {
        $packages_details{ $row->{module} } = $row->{dist};
    }

    my %used;
    my $distributions = $db->table('Distributions');
    my $requires      = $db->table('RequiresAndUses');
    my $errors        = $db->table('Errors');

    my $done = 0;
    my $total;
    if ($self->development_mode) {
        $total = $distributions->count;
    }

    my $iter = $distributions->iterate_name_and_uids;
    my %unindexed_errors;
    my %released;
    while (my $dist = $iter->next) {
        my $dist_name = $dist->{name};
        if ($done++ and !($done % 100)) {
            $self->show_progress($done, $total);
        }
        $released{$dist_name} = $dist->{last_released_at};
        for my $type (qw/latest_stable_uid latest_dev_uid/) {
            if (my $uid = $dist->{$type}) {
                if (my $json = $requires->select_requires_by_uid($uid)) {
                    my $data = decode_json($json);
                    for my $phase (keys %$data) {
                        for my $module (keys %{ $data->{$phase} }) {
                            next if $module eq 'perl';
                            my $name = $packages_details{$module};
                            if (!defined $name) {
                                my $module_version = $data->{$phase}{$module} // '';
                                my $message        = "$phase $module ($module_version) is not indexed";
                                push @{ $unindexed_errors{$uid} //= [] }, $message;
                                log(debug => "$dist_name: $message");
                                next;
                            }
                            $used{$name}{$dist_name}{ substr($phase, 0, 1) }{$module} //= $data->{$phase}{$module};
                        }
                    }
                }
            }
        }
    }
    for my $name (keys %used) {
        my $dist_used = $used{$name};
        $distributions->update_used_by($name, [map { [$_, $dist_used->{$_}] } sort { $released{$b} <=> $released{$a} } keys %$dist_used]);
    }
    my %known_errors = map { $_->{uid} => $_ } @{ $errors->select_all_errors_on("all_prereq_is_indexed") // [] };
    my @new;
    for my $uid (keys %unindexed_errors) {
        my $error = join "; ", sort @{ $unindexed_errors{$uid} // [] };
        if (!exists $known_errors{$uid}) {
            push @new, {
                uid      => $uid,
                category => "all_prereq_is_indexed",
                error    => $error,
            };
        } elsif ($error ne $known_errors{$uid}{error} // '') {
            $errors->update_error_by_id($known_errors{$uid}{id}, $error);
        }
        $known_errors{$uid}{_seen} = 1;
    }
    $errors->bulk_insert(\@new) if @new;
    my @delete_ids = map { $known_errors{$_}{id} } grep { !$known_errors{$_}{_seen} } keys %known_errors;
    $errors->delete_errors_by_id(\@delete_ids) if @delete_ids;
}

1;
