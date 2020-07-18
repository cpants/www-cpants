package WWW::CPANTS::Bin::Task::Traverse::UpdateAuthorJson;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::JSON;

our @READ  = qw/Authors/;
our @WRITE = qw/Authors/;

sub run ($self, @args) {
    my $db = $self->db;
    my $pause_ids =
        @args
        ? \@args
        : $db->table('Authors')->select_all_pause_ids_ordered_by_cpan_dists;
    my $cpan = $self->ctx->cpan;

    for my $pause_id (@$pause_ids) {
        my $author_dir = $cpan->author_dir($pause_id) or next;
        for my $file ($author_dir->children) {
            next if -d $file;

            if ($file->basename =~ m!^author(?:\-\d+)?\.json$!) {
                $self->update($pause_id, $file);
            }
        }
    }
}

sub update ($self, $pause_id, $file) {
    my $mtime = $file->stat->mtime;

    $self->log(info => "found $file");

    my $json = $self->slurp_and_fix_json($file) or return;

    $self->db->table('Authors')->update_json($pause_id, $json, $mtime);
}

sub slurp_and_fix_json ($self, $file) {
    my $json_text = $file->slurp;

    try {
        # eliminate spaces
        return encode_json(decode_json($json_text))
    } catch {
        my $json_error = $@;
        $json_error =~ s/ at \S+? line \d+.*$//s;
        $self->log(debug => "error found at $file: $json_error");
        $self->log(debug => $json_text);

        # illegal comments
        $json_text =~ s|",\s*//\s*.+$|",|gm;

        # coordinates
        $json_text =~ s|"location"\s*:\s*{lat\s*:\s*([0-9.-]+),\s*lon\s*:\s*([0-9.-]+)},|"location": {"lat": "$1", "lon": "$2"},|;

        try {
            # allow trailing commas
            return encode_json(decode_relaxed_json($json_text));
        } catch {
            $json_error = $@;
            $json_error =~ s/ at \S+? line \d+.*$//s;
            $self->log(warn => "error found at $file (even after relaxed): $json_error");
            return encode_json({ error => $json_error });
        }
    }
    return;
}

1;
