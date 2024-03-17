package WWW::CPANTS::Bin::Task::PostProcess::UpdateReverseDependency;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::CoreList;
use WWW::CPANTS::Util::JSON;

our @READ  = qw/RequiresAndUses/;
our @WRITE = qw/Distributions Errors/;

has 'packages'      => \&_build_packages;
has 'distributions' => \&_build_distributions;
has 'requires'      => \&_build_requires;
has 'errors'        => \&_build_errors;
has 'total'         => \&_build_total;

sub _build_distributions ($self) {
    $self->db->table('Distributions');
}

sub _build_requires ($self) {
    $self->db->table('RequiresAndUses');
}

sub _build_errors ($self) {
    $self->db->table('Errors');
}

sub _build_total ($self) {
    return if $self->ctx->quiet;
    $self->distributions->count;
}

sub run ($self, @args) {
    my $db   = $self->db;
    my $cpan = $self->ctx->cpan;

    $self->timer->total($self->total);

    my $done = 0;
    my (%used, %unindexed_errors, %last_release);
    my $iter = $self->distributions->iterate_name_and_uids;
    while (my $dist = $iter->next) {
        my $dist_name = $dist->{name};
        $self->timer->show_progress($done) if !(++$done % 100);
        $last_release{$dist_name} = $dist->{last_release_at};
        for my $type (qw/latest_stable_uid latest_dev_uid/) {
            if (my $uid = $dist->{$type}) {
                if (my $json = $self->requires->select_requires_by_uid($uid)) {
                    my $data = decode_json($json);
                    for my $phase (keys %$data) {
                        for my $module (keys %{ $data->{$phase} }) {
                            next if $module eq 'perl';
                            next if is_core($module);
                            my $name = $cpan->packages->distname($module);
                            if (!defined $name) {
                                my $module_version = $data->{$phase}{$module} // '';
                                my $message        = "$phase $module ($module_version) is not indexed";
                                push @{ $unindexed_errors{$uid} //= [] }, $message;
                                my $level = $module =~ /[A-Z:]/ ? 'debug' : 'info';
                                $self->log($level => "$dist_name: $message");
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
        $self->distributions->update_used_by(
            $name, [
                map  { [$_, $dist_used->{$_}] }
                sort { $last_release{$b} <=> $last_release{$a} }
                    keys %$dist_used
            ],
        );
    }

    my %known_errors = map { $_->{uid} => $_ } @{ $self->errors->select_all_errors_on("all_prereq_is_indexed") // [] };
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
            $self->errors->update_error_by_id($known_errors{$uid}{id}, $error);
        }
        $known_errors{$uid}{_seen} = 1;
    }
    $self->errors->bulk_insert(\@new) if @new;
    my @delete_ids = map { $known_errors{$_}{id} } grep { !$known_errors{$_}{_seen} } keys %known_errors;
    $self->errors->delete_errors_by_id(\@delete_ids) if @delete_ids;
}

1;
