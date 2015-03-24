package WWW::CPANTS::StatusImage;

use strict;
use warnings;
use WWW::CPANTS::AppRoot;
use WWW::CPANTS::Config;
use Imager;
use Imager::Font;
use Imager::Filter::RoundedCorner;

sub new {
  my ($class, $score) = @_;

  $score = sprintf '%.2f', $score;

  my $file = appdir("public/img/status/")->file("$score.png");

  if (!-f $file) {
    $file->parent->mkdir;
    $class->_generate($score)->write(file => $file);
  }
  bless {file => $file}, $class;
}

sub path {
  shift->{file}->relative(base => appdir("public"));
}

sub _generate {
  my ($class, $score) = @_;

  my $colors = $score >= 100 ? ["#090", "white"] :
               $score >=  90 ? ["#9f0", "black"] :
               $score >=  80 ? ["#ff0", "black"] :
                               ["#900", "white"] ;

  my $font = Imager::Font->new(%{ WWW::CPANTS::Config->font }, size => 11) or die;
  my $heading = $class->_size($font, "kwalitee");
  my $value   = $class->_size($font, "999.99");

  my $image = Imager->new(
    xsize => $heading->{xmax} + $value->{xmax},
    ysize => $heading->{ymax} + 5,
  );

  $image->box(@{$heading->{qw/xmin ymin xmax ymax/}},
              filled => 1, color => "#444");

  $image->box(xmin => $heading->{xmax}, ymin => $value->{ymin},
              xmax => $heading->{xmax} + $value->{xmax},
              ymax => $value->{ymax} + 5,
              filled => 1, color => $colors->[0]);

  $font->align(image => $image, string => 'kwalitee',
               color => 'white',
               x => $heading->{x},
               y => $heading->{y} + 2,
  );
  $font->align(image => $image, string => $score,
               color => $colors->[1],
               x => $heading->{xmax} + $value->{x},
               y => $value->{y} + 2,
  );
  $image->filter(
    type => 'rounded_corner',
    radius => 3,
    bg => '#fff',
  );

  $image;
}

sub _size {
  my ($class, $font, $string) = @_;
  my $bbox = $font->bounding_box(string => $string);
  my $font_h = $bbox->font_height;
  my $text_h = $bbox->text_height;
  my $margin = int(($font_h - $text_h) / 2);
  my $width = $bbox->advance_width;
  {
    xmin => 0,
    ymin => 0,
    xmax => $margin * 2 + $width + 3,
    ymax => $font_h + 2,
    x => $margin + 2,
    y => $font_h - $margin + 1,
  };
}

1;

__END__

=head1 NAME

WWW::CPANTS::StatusImage

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 path

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
