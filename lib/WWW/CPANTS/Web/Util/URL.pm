package WWW::CPANTS::Web::Util::URL;

use WWW::CPANTS;
use URI;
use URI::QueryParam;
use Gravatar::URL ();

sub metacpan_url ($dist) {
  URI->new(sprintf 'https://metacpan.org/release/%s/%s', @$dist{qw/author name_version/});
}

sub bugtracker_url ($dist) {
  if (my $url = $dist->{bugtracker_url}) {
    URI->new($url);
  } else {
    my $uri = URI->new('https://rt.cpan.org/Public/Dist/Display.html');
    $uri->query_param(Name => $dist->{name});
    $uri;
  }
}

sub repository_url ($dist) {
  my $url = $dist->{repository_url} or return;
  $url =~ s!^git://github!https://github!;
  URI->new($url);
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
