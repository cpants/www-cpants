package WWW::CPANTS::Web::Util::URL;

use Mojo::Base -strict, -signatures;
use Mojo::URL;
use Gravatar::URL  ();
use HTML::Entities ();
use Regexp::Common qw/URI/;

sub metacpan_url ($dist) {
    Mojo::URL->new(sprintf 'https://metacpan.org/release/%s/%s', @$dist{qw/author name_version/});
}

sub bugtracker_url ($dist) {
    if (my $url = $dist->{bugtracker_url}) {
        Mojo::URL->new($url);
    } else {
        $url = Mojo::URL->new('https://rt.cpan.org/Public/Dist/Display.html');
        $url->query(Name => $dist->{name});
        $url;
    }
}

sub repository_url ($dist) {
    my $url = $dist->{repository_url} or return;
    $url =~ s!^git://github!https://github!;
    Mojo::URL->new($url);
}

sub gravatar_url ($pause_id) {
    Gravatar::URL::gravatar_url(
        email   => ($pause_id // '__dummy__') . '@cpan.org',
        size    => 130,
        default => 'identicon',
        https   => 1,
    );
}

sub linkify ($text) {
    return '' unless defined $text;
    $text = HTML::Entities::encode_entities($text);
    $text =~ s!($RE{URI}{HTTP}{-scheme => 'https?'})!<a href="$1">$1</a>!gr;
}

1;
