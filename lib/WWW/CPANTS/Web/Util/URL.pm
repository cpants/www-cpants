package WWW::CPANTS::Web::Util::URL;

use WWW::CPANTS;
use URI;
use URI::QueryParam;
use Gravatar::URL ();

sub metacpan_url ($dist) {
  URI->new(sprintf 'https://metacpan.org/release/%s/%s', @$dist{qw/author name_version/});
}

sub search_cpan_url ($dist) {
  URI->new(sprintf 'http://search.cpan.org/~%s/%s/', lc $dist->{author}, $dist->{name_version});
}

sub rt_url ($dist) {
  my $uri = URI->new('https://rt.cpan.org/Public/Dist/Display.html');
  $uri->query_param(Name => $dist->{name});
  $uri;
}

sub gravatar_url ($pause_id) {
  Gravatar::URL::gravatar_url(
    email => $pause_id.'@cpan.org',
    size => 130,
    default => 'identicon',
    https => 1,
  );
}

1;
