package WWW::CPANTS::API::Util::Validate;

use Mojo::Base -strict, -signatures;
use Exporter qw/import/;

our @EXPORT = qw(
    is_int is_alphanum is_dist is_path is_pause_id
    is_availability_type
);

sub is_int ($value, $length = 19) {
    return unless defined $value;
    return unless $value =~ /\A[0-9]+\z/ && length($value) <= $length;
    return $value;
}

sub is_alphanum ($value, $length = 255) {
    return unless defined $value;
    return unless $value =~ /\A[0-9A-Za-z_\.\-\+]+\z/ && length($value) <= $length;
    return $value;
}

sub is_dist ($value, $length = 255) {
    return unless defined $value;
    return unless $value =~ /\A[0-9A-Za-z_\.\-\+]+\z/ && length($value) <= $length;
    return $value;
}

sub is_path ($value, $length = 255) {
    return unless defined $value;
    return unless $value =~ /\A[0-9A-Za-z_\.\-\/\+]+\z/ && length($value) <= $length;
    return $value;
}

sub is_pause_id ($value, $length = 9) {
    return unless defined $value;
    return unless length($value) <= $length;
    $value = uc $value;
    return unless $value =~ /\A[A-Z][A-Z0-9][0-9A-Z\-]*\z/;
    return $value;
}

my %availability = map { $_ => 1 } qw/latest cpan backpan/;
sub is_availability_type ($value) {
    return unless defined $value;
    return $value if exists $availability{$value};
}

1;
