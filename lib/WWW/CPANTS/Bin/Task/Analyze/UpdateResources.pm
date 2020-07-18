package WWW::CPANTS::Bin::Task::Analyze::UpdateResources;

use Role::Tiny::With;
use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::JSON;

our @WRITE = qw/Resources/;

with qw/WWW::CPANTS::Role::Task::FixAnalysis/;

sub update ($self, $uid, $stash) {
    return unless exists $stash->{meta_yml};
    return unless ref $stash->{meta_yml} eq 'HASH';
    return unless exists $stash->{meta_yml}{resources};
    return if $self->dry_run;

    my $pause_id  = $stash->{author};
    my $resources = $stash->{meta_yml}{resources};
    $resources = {} unless ref $resources eq 'HASH';

    my $repository = '';
    if ($resources->{repository}) {
        if (ref $resources->{repository} eq 'HASH') {
            $repository = $resources->{repository}{web} // $resources->{repository}{url};
        } elsif (!ref $resources->{repository}) {
            $repository = $resources->{repository};
        }
    }
    my $bugtracker = '';
    if ($resources->{bugtracker}) {
        if (ref $resources->{bugtracker} eq 'HASH') {
            $bugtracker = $resources->{bugtracker}{web};
        } elsif (!ref $resources->{bugtracker}) {
            $bugtracker = $resources->{bugtracker};
        }
    }

    $self->db->table('Resources')->update_resources($uid, $pause_id, encode_json($resources), $repository, $bugtracker);
}

1;
