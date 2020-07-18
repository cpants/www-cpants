package WWW::CPANTS::Bin::Task::Analyze::UpdateKwalitee;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::Datetime qw/year/;

our @READ  = qw/Analysis/;
our @WRITE = qw/Kwalitee/;

with qw/WWW::CPANTS::Role::Task::FixAnalysis/;

sub update ($self, $uid, $stash) {
    return unless exists $stash->{kwalitee};

    return if $self->dry_run;

    $self->ctx->kwalitee->set_scores($stash);

    my $pause_id     = $stash->{author};
    my $distribution = $stash->{dist};
    my $kwalitee     = $stash->{kwalitee};

    $self->db->table('Kwalitee')->update_kwalitee($uid, $pause_id, $distribution, year($stash->{released_epoch}), $kwalitee);
}

1;
