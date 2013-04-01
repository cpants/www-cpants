use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @paths = (
  'I/IN/INA/Char/Latin10/Char-Latin10-0.87.tar.gz',
);

my $mirror = setup_mirror(@paths);

my $analyzer = WWW::CPANTS::Analyze->new;
for my $path (@paths) {
  my $context = $analyzer->analyze(dist => $mirror->file($path));
  ok $context, "has context";
  ok $context && $context->stash->{extracts_nicely}, "extracts nicely";
}

done_testing;
