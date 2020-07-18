package WWW::CPANTS::Bin::Task::Traverse::UpdateCPANStatus;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;

our @READ  = qw/Authors Uploads/;
our @WRITE = qw/Uploads Kwalitee/;

has 'changed' => sub ($self) { +{} };
has 'uid_map' => sub ($self) { +{} };

sub run ($self, @args) {
    # FIXME
}

sub load_uids_for ($self, $pause_id) {
    my %map = map { $_ => 0 } $self->db->table('Uploads')->select_all_cpan_uids_by_author($pause_id)->@*;
    $self->uid_map(\%map);
    $self->changed({});
}

sub has_uid ($self, $uid) {
    exists $self->uid_map->{$uid} ? 1 : 0;
}

sub mark ($self, $uid) {
    if (!$self->uid_map->{$uid}) {
        $self->changed->{$uid} = 1;
    }
    $self->uid_map->{$uid} = 1;
}

sub removed_uids ($self) {
    grep { !$self->uid_map->{$_} } keys $self->uid_map->%*;
}

sub changed_cpan_uids ($self) {
    grep { $self->changed->{$_} } keys $self->uid_map->%*;
}

sub mark_backpan ($self) {
    my $db = $self->db;
    if (my @removed_uids = $self->removed_uids) {
        $db->table('Uploads')->mark_backpan(\@removed_uids);
        $db->table('Kwalitee')->mark_backpan(\@removed_uids);
    }
}

sub mark_cpan ($self) {
    my $db = $self->db;
    if (my @cpan_uids = $self->changed_cpan_uids) {
        $db->table('Uploads')->mark_cpan(\@cpan_uids);
        $db->table('Kwalitee')->mark_cpan(\@cpan_uids);
    }
}

1;
