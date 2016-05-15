package WWW::CPANTS::Bin::Task::Analyze::UpdateKwalitee;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use parent 'WWW::CPANTS::Bin::Task';

sub run ($self, @args) {
  # FIXME
}

sub setup ($self, $db = undef) {
  $self->{db} = $db //= $self->db;
  $self->{table} = $db->table('Kwalitee');
  $self;
}

sub update ($self, $uid, $stash) {
  return unless exists $stash->{kwalitee};

  my $pause_id = $stash->{author};
  my $kwalitee = $stash->{kwalitee};

  $self->{table}->update_kwalitee($uid, $pause_id, year($stash->{released_epoch}), $kwalitee);
}

1;
