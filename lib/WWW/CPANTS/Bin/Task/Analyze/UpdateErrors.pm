package WWW::CPANTS::Bin::Task::Analyze::UpdateErrors;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Util::HideInternal;
use Encode;

our @READ  = qw/Analysis Errors/;
our @WRITE = qw/Errors/;

with qw/WWW::CPANTS::Role::Task::FixAnalysis/;

sub update ($self, $uid, $stash) {
    my $table = $self->db->table('Errors');

    return if $self->dry_run;

    # make a shallow copy
    my %errors = %{ $stash->{error} // {} };
    if (!%errors) {
        $table->delete_errors_by_uid($uid);
        return;
    }

    my (@updated, @deleted, @new);
    for my $row (@{ $table->select_errors_by_uid($uid) // [] }) {
        my $category = $row->{category};
        my $error    = delete $errors{$category};
        if (!defined $error) {
            push @deleted, $row->{id};
            next;
        }

        if (ref $error) {
            $error = hide_internal(encode_json($error));
            if (my $diff = json_diff($error, $row->{error})) {
                push @updated, [$row->{id}, $error];
            }
        } else {
            $error = encode_utf8(hide_internal($error));
            if ($error ne $row->{error}) {
                push @updated, [$row->{id}, $error];
            }
        }
    }

    for my $category (keys %errors) {
        my $error = $errors{$category};
        push @new, {
            uid      => $uid,
            category => $category,
            error    => hide_internal(ref $error ? encode_json($error) : $error),
        };
    }

    if (@new) {
        $table->bulk_insert(\@new);
    }
    if (@updated) {
        $table->update_error_by_id(@$_) for @updated;
    }
    if (@deleted) {
        $table->delete_errors_by_id(\@deleted);
    }
    return @new + @updated + @deleted;
}

1;
