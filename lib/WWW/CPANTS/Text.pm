package WWW::CPANTS::Text;

use strict;
use warnings;
use Text::Markdown ();
use Exporter::Lite;
use WWW::CPANTS::AppRoot;
use Mojo::Template;

our @EXPORT = qw/markdown/;

my $parser = Text::Markdown->new;

sub markdown {
  my ($path, @args) = @_;
  my $cachefile = file("data/$path.md.html");
  my $mdfile = file("texts/$path.md");
  return "" unless -f $mdfile;

  if (-f $cachefile) {
    my $mtime = $cachefile->mtime;
    if ((!@args or $mtime > time - 24 * 60 * 60) and $mtime > $mdfile->mtime) {
      return scalar $cachefile->slurp;
    }
    $cachefile->remove;
  }

  my $text = $mdfile->slurp;
  return "" unless $text;

  if (@args) {
    my $template = Mojo::Template->new;
    $text = $template->render($text, @args);
  }

  if (my $html = $parser->markdown($text)) {
    $cachefile->save($html, mkdir => 1);
    return $html;
  }
  return "";
}

1;

__END__

=head1 NAME

WWW::CPANTS::Text

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 markdown

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
