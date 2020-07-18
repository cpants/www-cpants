package WWW::CPANTS::Bin::Task::Analyze::UpdateErrors;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use parent 'WWW::CPANTS::Bin::Task';

sub run ($self, @args) {
    # FIXME
}

sub setup ($self, $db = undef) {
    $self->{db}    = $db //= $self->db;
    $self->{table} = $db->table('Errors');
    $self;
}

sub update ($self, $uid, $stash) {
    return unless exists $stash->{error};

    my $errors = $stash->{error};
    return unless %$errors;

    my $table = $self->{table};

    my (@updated, @deleted, @new, %seen);
    for my $row (@{ $table->select_errors_by_uid($uid) // [] }) {
        $seen{ $row->{category} } = 1;
        my $e = $errors->{ $row->{category} };
        if (!defined $e) {
            push @deleted, $row->{id};
            next;
        }
        if ((ref $e && diff_json($e, $row->{error})) or $e ne $row->{error}) {
            push @updated, [$e, $row->{id}];
        }
    }
    for my $category (keys %$errors) {
        next if $seen{$category};
        my $e = $errors->{$category};
        push @new, {
            uid      => $uid,
            category => $category,
            error    => hide_internal(ref $e ? encode_json($e) : $e),
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
}

1;
