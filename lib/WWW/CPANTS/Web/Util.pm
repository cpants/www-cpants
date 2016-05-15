package WWW::CPANTS::Web::Util;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use HTML::Entities ();
use Exporter qw/import/;

our @EXPORT = (
  @WWW::CPANTS::Util::EXPORT,
  qw/
    page api4 html
  /,
);

my %LOADABLE = map {$_ => 1}
  (findallmod 'WWW::CPANTS::Web::Page'),
  (findallmod 'WWW::CPANTS::Web::API::V4'),
;

my %LOADED;

sub _data ($name, @args) {
  my $package = "WWW::CPANTS::Web::".$name;
  return WWW::CPANTS::Web::Data->new unless $LOADABLE{$package};

  $LOADED{$package} //= use_module($package);
  $package->new(@args);
}

sub page ($name, @args) { _data("Page::$name", @args) }
sub api4 ($name, @args) { _data("API::V4::$name", @args) }

sub html (@args) { HTML::Entities::encode_entities(@args) }

1;
