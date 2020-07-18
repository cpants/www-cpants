package WWW::CPANTS::API::Util::Format;

use Mojo::Base -strict, -signatures;
use Exporter qw/import/;

our @EXPORT = qw(
    percent decimal kwalitee_score
    release_availability
);

sub kwalitee_score ($score) { $score ? 0 + sprintf '%.2f', $score : 0 }

sub decimal ($decimal) {
    0 + sprintf '%0.2f', int(($decimal || 0) * 100 + 0.5) / 100;
}

sub percent ($numerator, $denominator) {
    decimal(($numerator || 0) / ($denominator || 100) * 100);
}

sub release_availability ($release) {
    return "" unless ref $release eq 'HASH';
    return "Latest Dev" if $release->{latest} && !$release->{stable};
    return "Latest"     if $release->{latest} && $release->{stable};
    return "CPAN"       if $release->{cpan};
    return "BackPAN";
}

1;
