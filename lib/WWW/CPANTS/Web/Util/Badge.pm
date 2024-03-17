package WWW::CPANTS::Web::Util::Badge;

use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Util::Path;
use Badge::Simple;
use Imager;
use Imager::Font;
use Imager::Filter::RoundedCorner;
use Exporter     qw/import/;
use experimental qw/switch/;
no warnings qw/deprecated/;

our @EXPORT = qw/badge/;

our %FontConfig = (
      ($^O eq 'MSWin32') ? (face => 'Meiryo UI')
    : ($^O eq 'darwin')  ? (file => '/Library/Fonts/Verdana.tff')
    :                      (file => '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'));

sub badge ($score, $format) {
    return unless $score && $score =~ /\A[0-9.]+\z/;
    $score = sprintf '%.2f', $score;

    my $pub_dir = cpants_path('public');
    my $file    = $pub_dir->child("img/badge/$score.$format");

    if (!-f $file) {
        $file->parent->mkpath;
        given ($format) {
            when ('png') {
                _generate_png_badge($score, $file);
            }
            when ('svg') {
                _generate_svg_badge($score, $file);
            }
        }
    }
    return $file->relative($pub_dir);
}

sub _generate_svg_badge ($score, $file) {
    my $color =
          $score >= 100 ? 'brightgreen'
        : $score >= 99  ? 'green'
        : $score >= 90  ? 'yellowgreen'
        : $score >= 80  ? 'yellow'
        :                 'red';
    Badge::Simple::badge(left => 'kwalitee', right => $score, color => $color)->toFile("$file");

}

sub _generate_png_badge ($score, $file) {
    my $colors =
          $score >= 100 ? ["#090", "white"]
        : $score >= 90  ? ["#9f0", "black"]
        : $score >= 80  ? ["#ff0", "black"]
        :                 ["#900", "white"];

    my $font    = Imager::Font->new(%FontConfig, size => 11) or Carp::croak "Can't load font";
    my $heading = _size($font, "kwalitee");
    my $value   = _size($font, "999.99");

    my $image = Imager->new(
        xsize => $heading->{xmax} + $value->{xmax},
        ysize => $heading->{ymax} + 5,
    );

    $image->box(
        @{ $heading->{qw/xmin ymin xmax ymax/} },
        filled => 1, color => "#444"
    );

    $image->box(
        xmin   => $heading->{xmax}, ymin => $value->{ymin},
        xmax   => $heading->{xmax} + $value->{xmax},
        ymax   => $value->{ymax} + 5,
        filled => 1, color => $colors->[0]);

    $font->align(
        image => $image, string => 'kwalitee',
        color => 'white',
        x     => $heading->{x},
        y     => $heading->{y} + 2,
    );
    $font->align(
        image => $image, string => $score,
        color => $colors->[1],
        x     => $heading->{xmax} + $value->{x},
        y     => $value->{y} + 2,
    );
    $image->filter(
        type   => 'rounded_corner',
        radius => 3,
        bg     => '#fff',
    );

    $image->write(file => $file);
}

sub _size ($font, $string) {
    my $bbox   = $font->bounding_box(string => $string);
    my $font_h = $bbox->font_height;
    my $text_h = $bbox->text_height;
    my $margin = int(($font_h - $text_h) / 2);
    my $width  = $bbox->advance_width;
    {
        xmin => 0,
        ymin => 0,
        xmax => $margin * 2 + $width + 3,
        ymax => $font_h + 2,
        x    => $margin + 2,
        y    => $font_h - $margin + 1,
    };
}

1;
