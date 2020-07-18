package WWW::CPANTS::Util::Distname;

use Mojo::Base -strict, -signatures;
use Parse::Distname qw/parse_distname/;
use Exporter qw/import/;
use WWW::CPANTS::Util::PathUid;

our @EXPORT = qw/valid_distinfo distinfo distname_info/;

sub fix_path ($path) {
    return $path if $path =~ m|^([A-Z])/(\1[A-Z0-9])/\2[A-Z0-9\-]*/|;

    if (my ($pause_id) = $path =~ m|^([A-Z][A-Z0-9][A-Z0-9\-]*)/|) {
        return join '/',
            substr($pause_id, 0, 1),
            substr($pause_id, 0, 2),
            $path;
    }

    my $message = "Illegal CPAN path: $path";
    Carp::croak $message;
}

sub valid_distinfo ($file) {
    my $info = parse_distname($file);
    return if delete $info->{perl6};
    return if !defined $info->{name} or $info->{name} eq '';
    my $uid = path_uid($info->{cpan_path}) or return;
    return {
        filename  => "$file",
        path      => $info->{cpan_path},
        author    => $info->{pause_id},
        name      => $info->{name},
        version   => $info->{version},
        maturity  => ($info->{is_dev} ? 'developer' : 'released'),
        stable    => ($info->{is_dev} ? 0 : 1),
        distvname => $info->{name_and_version},
        extension => substr($info->{extension} // '.', 1),
        uid       => $uid,
    };
}

sub distinfo ($file) {
    my $info = parse_distname($file);
    return {
        filename  => "$file",
        path      => $info->{cpan_path},
        author    => $info->{pause_id},
        name      => $info->{name},
        version   => $info->{version},
        maturity  => ($info->{is_dev} ? 'developer' : 'released'),
        distvname => $info->{name_and_version},
        extension => substr($info->{extension} // '.', 1),
    };
}

sub distname_info ($distv) {
    my $info = Parse::Distname::_parse_distv($distv);
    @$info{qw/name version/};
}

1;
