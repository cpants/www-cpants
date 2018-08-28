package WWW::CPANTS::Bin::Util::UserAgent;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use Exporter qw/import/;
use HTTP::Tiny;
use URI;
use URI::QueryParam;

our @EXPORT = qw/http_get mirror metacpan_api/;

my $UA = HTTP::Tiny->new();
my $CPAN_API = 'https://fastapi.metacpan.org/v1';

sub http_get ($url) {
  my $res = $UA->get($url);
}

sub mirror ($url, $file) {
  log(notice => "mirroring from $url to $file");
  my $res = $UA->mirror($url => $file);
  if (!$res->{success}) {
    my $message = "Can't mirror $url: $res->{code} $res->{reason}";
    log(error => $message);
    croak $message;
  }
}

sub metacpan_api ($path, $query = {}) {
  $path =~ s|^/||;
  my $url = URI->new("$CPAN_API/$path");
  $url->query_param($_ => $query->{$_}) for keys %$query;
  my $res = http_get($url);
  if (!$res->{success}) {
    my $message = "MetaCPAN API error ($url): $res->{code} $res->{reason}";
    log(error => $message);
    croak $message;
  }
  return decode_json($res->{content});
}

1;
