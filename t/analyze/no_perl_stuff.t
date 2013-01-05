use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @paths = (
  'H/HM/HMBRAND/cshmen-3.50_01.tgz',
);

my $mirror = setup_mirror(@paths);

my $analyzer = WWW::CPANTS::Analyze->new;
for my $path (@paths) {
  my $context = $analyzer->analyze(dist => $mirror->file($path));
  ok $context, "has context";
  ok $context && $context->stash->{has_no_perl_stuff}, "flag is set correctly";
}

done_testing;
