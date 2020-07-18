package WWW::CPANTS::Bin::Task::ParseRecentJson;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::Distname;

has 'register_new' => \&_build_register_new;
has 'update_dists' => \&_build_update_dists;
has 'cpan_status'  => \&_build_cpan_status;

has 'type' => '6h';

sub _build_register_new ($self) {
    $self->subtask('RegisterNew');
}

sub _build_update_dists ($self) {
    $self->subtask('Traverse::UpdateDistributions');
}

sub _build_cpan_status ($self) {
    $self->subtask('Traverse::UpdateCPANStatus');
}

sub subtasks ($self) {
    return [
        $self->register_new,
        $self->update_dists,
        $self->cpan_status,
    ];
}

sub run ($self, @args) {
    my $type = $self->type;

    $self->log(info => "parsing RECENT-$type.json");

    my $dists = $self->cpan->recent->type($type)->distributions;

    my %seen;
    my @rows;
    for my $dist (@$dists) {
        my $row = valid_distinfo($dist->{path}) or next;

        my $file = $self->ctx->cpan->distribution($row->{path});
        next unless $file->exists;    # not rsynched yet

        $row->{released} = int($dist->{epoch} // $file->stat->mtime);
        $row->{cpan}     = 1;

        my $uid = $row->{uid};

        if ($seen{$uid}++) {
            $self->log(error => "Duplicated uid: $uid ($dist->{path})");
            next;
        }

        $self->cpan_status->mark($uid);
        $self->update_dists->mark($row, 1);

        push @rows, $row;
    }
    return unless @rows;

    $self->cpan_status->mark_backpan;
    $self->cpan_status->mark_cpan;

    my $registered = $self->register_new->register_if_new(\@rows) or return;

    $self->update_dists->finalize;

    $self->log(notice => "inserted $registered new CPAN distributions");
}

1;
