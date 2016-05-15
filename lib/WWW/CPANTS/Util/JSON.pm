package WWW::CPANTS::Util::JSON;

use WWW::CPANTS;
use WWW::CPANTS::Util::Path;
use Module::Runtime qw/use_module/;
use Exporter qw/import/;
use JSON::Diffable ();
use Text::Diff ();

our @EXPORT = qw/
  slurp_json save_json json_file json_dir
  decode_json decode_relaxed_json decode_if_json
  encode_json encode_pretty_json
  diff_json
/;

my $JSON_CLASS = use_module($ENV{CPAN_META_JSON_BACKEND} || $ENV{PERL_JSON_BACKEND} || 'JSON::XS');
my $JSON = $JSON_CLASS->new->utf8->canonical->convert_blessed(1);

sub decode_json ($json) { my $val = eval { $JSON->decode($json) }; confess $@ if $@; $val }
sub decode_relaxed_json ($json) { $JSON->relaxed->decode($json) }
sub encode_json ($data) { $JSON->encode($data) }
sub encode_pretty_json ($data) { $JSON->pretty->encode($data) }
sub diff_json ($old, $new) {
  return if $old eq $new;
  $old = JSON::Diffable::encode_json(decode_if_json($old // {}));
  $new = JSON::Diffable::encode_json(decode_if_json($new // {}));
  return if $old eq $new;
  Text::Diff::diff(\$old, \$new, {STYLE => 'Unified'});
}

sub decode_if_json ($maybe_json) {
  return $maybe_json unless $maybe_json =~ /^[\[{]/;
  decode_relaxed_json($maybe_json);
}

sub json_file ($path) {
  file($path =~ /\.json$/ ? $path : "tmp/json/$path.json");
}

sub json_dir ($path) {
  dir("tmp/json/$path");
}

sub slurp_json ($name) {
  my $file = json_file($name);
  return unless $file->exists;
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

# to convert version objects in the stash
# XXX: of course it's best not to use these costly conversions

{
  no warnings 'redefine';
  sub version::TO_JSON { "$_[0]" }
  sub Module::Build::Version::TO_JSON { "$_[0]" }
}

1;
