package WWW::CPANTS::Role::Task::FixAnalysis;

use Mojo::Base -role, -signatures;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Util::HideInternal;
use WWW::CPANTS::Util::PathUid;
use Parse::Distname qw/parse_distname/;

sub run ($self, @args) {
    if (@args) {
        $self->fix_with_args(\@args);
    } else {
        $self->fix_all;
    }
}

sub fix_all ($self) {
    my $table    = $self->db->table('Analysis');
    my $iterator = $table->iterate;
    while (my $row = $iterator->next) {
        my ($uid, $path, $json) = @$row{qw/uid path json/};
        next unless $json;
        my $stash = decode_json($json);
        $self->update($uid, $stash) or next;
        $self->log(info => "fixed $path");

        if ($self->dump) {
            say hide_internal(encode_pretty_json($stash));
        }
    }
}

sub fix_with_args ($self, $args) {
    my $table = $self->db->table('Analysis');
    for my $path (@$args) {
        next unless defined $path and $path ne '';
        my $info = parse_distname($path);
        if (!$info) {
            $self->log(error => "$path seems not a CPAN distribution");
            next;
        }

        $path = $info->{cpan_path};
        my $uid   = path_uid($path);
        my $json  = $table->select_json_by_uid($uid) or next;
        my $stash = decode_json($json);
        $self->update($uid, $stash) or next;
        $self->log(info => "fixed $path");

        if ($self->dump) {
            say hide_internal(encode_pretty_json($stash));
        }
    }
}

1;
