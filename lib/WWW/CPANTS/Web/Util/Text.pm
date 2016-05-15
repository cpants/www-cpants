package WWW::CPANTS::Web::Util::Text;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use Exporter qw/import/;
use Text::Markdown::Hoedown ();
use Mojo::Template;

our @EXPORT = qw/markdown/;

sub markdown ($path, @args) {
  my $cache_file = file("tmp/html/$path.md.html");
  my $text_file = file("web/text/$path.md");
  return unless -f $text_file;

  if (-f $cache_file && !@args) {
    if ($cache_file->stat->mtime > $text_file->stat->mtime) {
      return $cache_file->slurp_utf8;
    }
    $cache_file->remove;
  }

  my $text = $text_file->slurp_utf8 // "";

  if (@args) {
    $text = Mojo::Template->new->render($text, @args);
  }

  my $html = Text::Markdown::Hoedown::markdown($text) or return "";

  if (!@args) {
    $cache_file->parent->mkpath;
    $cache_file->spew_utf8($html);
  }
  $html;
}

1;
