package WWW::CPANTS::Util::JSON;

use Mojo::Base -strict, -signatures;
use Mojo::JSON::Pointer;
use Exporter          qw/import/;
use JSON::XS          ();
use Scalar::Util      qw/blessed/;
use String::CamelCase qw/camelize/;
use Syntax::Keyword::Try;
use WWW::CPANTS::Util::Path;
use WWW::CPANTS::Util::Diff;

our @EXPORT = qw(
    slurp_json save_json save_pretty_json json_file json_dir
    decode_json decode_relaxed_json decode_if_json
    encode_json encode_pretty_json get_partial_json_data
    json_true json_false
    json_diff
);

my $JSON = JSON::XS->new->utf8->canonical->allow_nonref(1)->convert_blessed(1);

sub decode_json ($json) {
    try { return $JSON->decode($json) }
    catch { Carp::confess $@ }
}

sub decode_relaxed_json ($json) { $JSON->relaxed->decode($json) }

sub encode_json ($data) { $JSON->encode($data) }

sub encode_pretty_json ($data) { $JSON->pretty->space_before(0)->encode($data) }

sub json_diff ($old, $new) {
    $old = _make_diffable($old);
    $new = _make_diffable($new);
    return if $old eq $new;
    diff(\$old, \$new);
}

sub _make_diffable ($json) {
    $json = encode_pretty_json(ref $json ? $json : decode_json($json));
    $json =~ s/(["}\]]|true|false|null)\n/$1,\n/gs;
    $json =~ s/([}\]]),\n$/$1\n/gs;
    $json;
}

sub decode_if_json ($maybe_json) {
    return $maybe_json unless $maybe_json =~ /^[\[{]/;
    decode_relaxed_json($maybe_json);
}

sub json_file ($path) {
    $path = camelize($path =~ s|::|/|gr) if $path =~ /::/;
    return $path                         if blessed $path and $path->isa('Path::Tiny');
    cpants_path($path =~ /\.json$/ ? $path : "tmp/json/$path.json");
}

sub json_dir ($path) {
    cpants_path("tmp/json/$path");
}

sub slurp_json ($name) {
    my $file = json_file($name);
    return unless -f $file;
    my $json = $file->slurp_utf8;
    return unless defined $json;
    decode_json($json);
}

sub save_json ($name, $data = undef) {
    my $file = json_file($name);
    if (defined $data) {
        $file->parent->mkpath;
        $file->spew_utf8(encode_json($data));
    } else {
        $file->remove if $file->exists;
    }
}

sub save_pretty_json ($name, $data = undef) {
    my $file = json_file($name);
    if (defined $data) {
        $file->parent->mkpath;
        $file->spew_utf8(encode_pretty_json($data));
    } else {
        $file->remove if $file->exists;
    }
}

sub json_true ()  { JSON::XS->true }
sub json_false () { JSON::XS->false }

sub get_partial_json_data ($data, $selector) {
    Mojo::JSON::Pointer->new($data)->get($selector);
}

# to convert version objects in the stash
# XXX: of course it's best not to use these costly conversions

{
    no warnings 'redefine';
    sub version::TO_JSON                { "$_[0]" }
    sub Module::Build::Version::TO_JSON { "$_[0]" }
}

1;
