package WWW::CPANTS::Bin::Task::Traverse::UpdateAuthorJson;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use parent 'WWW::CPANTS::Bin::Task';

sub run ($self, @args) {
    # FIXME
}

sub setup ($self) {
    my $db = $self->db;
    $self->{table} = my $table = $db->table('Authors');
    my %map = map { $_->{pause_id} => $_->{json_updated_at} } @{ $table->select_all_json_updated_at // [] };
    $self->{mtime} = \%map;
    $self;
}

sub update ($self, $pause_id, $file) {
    my $json;
    my $mtime = file_mtime($file);
    if ($self->{mtime}{$pause_id}) {
        return if $self->{mtime}{$pause_id} > $mtime;
    }
    $self->{mtime}{$pause_id} = $mtime;
    my $name = $file->basename;
    log(info => "found $name for $pause_id");
    my $json_text = $file->slurp;
    try {
        # eliminate spaces
        $json = encode_json(decode_json($json_text));
    } catch {
        my $json_error = $@;
        $json_error =~ s/ at \S+? line \d+.*$//s;
        log(debug => "error found at $pause_id/$name: $json_error");
        log(debug => $json_text);
        my $tweaked_json_text = $json_text;
        $tweaked_json_text =~ s|",\s*//\s*.+$|",|gm;                                                                                          # illegal comments
        $tweaked_json_text =~ s|"location"\s*:\s*{lat\s*:\s*([0-9.-]+),\s*lon\s*:\s*([0-9.-]+)},|"location": {"lat": "$1", "lon": "$2"},|;    # coordinates
        try {
            # allow trailing commas
            $json = encode_json(decode_relaxed_json($tweaked_json_text));
        } catch {
            $json_error = $@;
            $json_error =~ s/ at \S+? line \d+.*$//s;
            log(info => "error found at $pause_id/$name (even after relaxed): $@");
            encode_json({ error => $json_error });
        }
    }
    $self->{table}->update_json($pause_id, $json, $self->{mtime}{$pause_id}) if $json;
}

1;
