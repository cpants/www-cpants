package WWW::CPANTS::Util;

use WWW::CPANTS;
use WWW::CPANTS::Util::Path;
use WWW::CPANTS::Util::Log;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Util::CoreList;
use WWW::CPANTS::Util::Datetime;
use WWW::CPANTS::Util::DistnameInfo;
use Exporter qw/import/;
use Module::Find qw/findallmod useall/;
use Module::Runtime qw/use_module/;
use String::CamelCase qw/camelize decamelize/;
use Const::Fast;
use Try::Catch;
use Digest::MD5 ();
use Digest::FNV::XS ();
use Scalar::Util qw/blessed/;
use version;

use lib glob app_dir("extlib/*/lib")->path;

our @EXPORT = (
  @WWW::CPANTS::Util::Path::EXPORT,
  @WWW::CPANTS::Util::Log::EXPORT,
  @WWW::CPANTS::Util::JSON::EXPORT,
  @WWW::CPANTS::Util::CoreList::EXPORT,
  @WWW::CPANTS::Util::Datetime::EXPORT,
  @WWW::CPANTS::Util::DistnameInfo::EXPORT,
  @Const::Fast::EXPORT,
  @Try::Catch::EXPORT,
  qw/
    under_maintenance
    under_analysis
    package_path_name
    use_module
    decamelize camelize
    md5
    path_uid
    findallmod useall
    blessed
    try_and_log_error
    config
    distinfo
    file_mtime
    hide_internal
    is_int is_alphanum is_dist is_path is_pause_id is_availability_type
    release_availability
    decimal percent
  /,
);

# Unfortunately Cpanel::JSON::XS spits redefine warnings
# if JSON::PP happens to be loaded later (Cpanel::JSON::XS#65)
# $ENV{CPAN_META_JSON_BACKEND} = 'JSON::MaybeXS';
$ENV{PERL_JSON_BACKEND} = 'JSON::XS'; # fallback for old PCM

sub under_maintenance () { -f file('__maintenance__') ? 1 : 0 }
sub under_analysis ()    { -f file('__analyzing__') ? 1 : 0 }

sub package_path_name ($package) {
  decamelize($package =~ s|::|/|gr);
}

sub md5 ($str) { Digest::MD5::md5_hex($str) }
sub path_uid ($str) { Digest::FNV::XS::fnv1a_64($str) }

sub try_and_log_error :prototype(&) ($code) {
  try {$code->()}
  catch { my $error = $_; log(error => $error); return };
}

sub config ($name) {
  my $ctx = WWW::CPANTS->context or return;
  $ctx->_config($name);
}

sub file_mtime ($file) { (stat("$file"))[9] }

sub hide_internal ($str) {
  my $root = WWW::CPANTS::Util::Path::app_root();
  my ($home) = $root =~ m|^((?:[A-Z]:)?/home/[^/]+)|i;
  no warnings 'uninitialized';
  $str =~ s!$home/\.plenv/versions/[^/]+/lib/perl5/(site_perl/)?5\.\d+\.\d+/!$1lib/!g;
  $str =~ s!$home/((?:backpan|cpan)/)!$1!g;
  $str =~ s!$root/tmp/analyze/[^/]+/[^/]+/!!g;
  $str =~ s!$root/extlib/[^/]+/!!g;
  $str =~ s!$root/!!g;
  $str =~ s!$home/!!g;
  $str;
}

sub is_int ($value, $length = 19) {
  return unless defined $value;
  return unless $value =~ /\A[0-9]+\z/ && length($value) <= $length;
  return $value;
}

sub is_alphanum ($value, $length = 255) {
  return unless defined $value;
  return unless $value =~ /\A[0-9A-Za-z_\.\-]+\z/ && length($value) <= $length;
  return $value;
}

sub is_dist ($value, $length = 255) {
  return unless defined $value;
  return unless $value =~ /\A[0-9A-Za-z_\.\-]+\z/ && length($value) <= $length;
  return $value;
}

sub is_path ($value, $length = 255) {
  return unless defined $value;
  return unless $value =~ /\A[0-9A-Za-z_\.\-\/]+\z/ && length($value) <= $length;
  return $value;
}

sub is_pause_id ($value, $length = 9) {
  return unless defined $value;
  return unless length($value) <= $length;
  $value = uc $value;
  return unless $value =~ /\A[A-Z][A-Z0-9][0-9A-Z\-]+\z/;
  return $value;
}

my %availability = map {$_ => 1} qw/latest cpan backpan/;
sub is_availability_type ($value) {
  return unless defined $value;
  return $value if exists $availability{$value};
}

sub release_availability ($release) {
  return "" unless ref $release eq 'HASH';
  return "Latest Dev" if $release->{latest} && !$release->{stable};
  return "Latest" if $release->{latest} && $release->{stable};
  return "CPAN" if $release->{cpan};
  return "BackPAN";
}

sub decimal {
  my $decimal = shift || 0;
  sprintf '%0.2f', int($decimal * 100 + 0.5) / 100;
}

sub percent {
  my ($numerator, $denominator) = @_;
  decimal($numerator / ($denominator || 100) * 100);
}

1;
