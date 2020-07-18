package WWW::CPANTS::Web::Util::Badge;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use Imager;
use Imager::Font;
use Imager::Filter::RoundedCorner;

sub new ($class, $score) {
    $score = sprintf '%.2f', $score if $score =~ /^[0-9.]+$/;
    my $file = app_dir('web/public/img/badge/')->child("$score.png");
    if (!-f $file) {
        $file->parent->mkpath;
        $class->_generate($score)->write(file => $file);
    }
    bless { file => $file }, $class;
}

sub path ($self) {
    $self->{file}->relative(app_dir('web/public'));
}

sub _generate ($class, $score) {
    my $colors =
          $score >= 100 ? ["#090", "white"]
        : $score >= 90  ? ["#9f0", "black"]
        : $score >= 80  ? ["#ff0", "black"]
        :                 ["#900", "white"];

    my $font    = Imager::Font->new(%{ config('font') // {} }, size => 11) or croak "Can't load font";
    my $heading = $class->_size($font, "kwalitee");
    my $value   = $class->_size($font, "999.99");

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

    $image;
}

sub _size ($class, $font, $string) {
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
