package WWW::CPANTS::Bin::Task::Analyze::UpdateResources;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use parent 'WWW::CPANTS::Bin::Task';

sub run ($self, @args) {
    # FIXME
}

sub setup ($self, $db = undef) {
    $self->{db}    = $db //= $self->db;
    $self->{table} = $db->table('Resources');
    $self;
}

sub update ($self, $uid, $stash) {
    return unless exists $stash->{meta_yml};
    return unless ref $stash->{meta_yml} eq 'HASH';
    return unless exists $stash->{meta_yml}{resources};

    my $pause_id  = $stash->{author};
    my $resources = $stash->{meta_yml}{resources};

    my $repository =
          ($resources->{repository} && ref $resources->{repository} eq 'HASH') ? $resources->{repository}{web} // $resources->{repository}{url}
        : (!ref $resources->{repository}) ? $resources->{repository}
        :                                   '';
    my $bugtracker =
          ($resources->{bugtracker} && ref $resources->{bugtracker} eq 'HASH') ? $resources->{bugtracker}{web}
        : (!ref $resources->{bugtracker}) ? $resources->{bugtracker}
        :                                   '';

    $self->{table}->update_resources($uid, $pause_id, encode_json($resources), $repository, $bugtracker);
}

1;
