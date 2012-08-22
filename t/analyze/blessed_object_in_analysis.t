use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @paths = (
  # meta_yml/version
  'S/SU/SUNNAVY/BBS-Perm-v0.0.3.tar.gz',

  # meta_yml/abstract
  'A/AS/ASCOPE/MT-Import-Mbox-Importer-1.0.tar.gz',

  # meta_yml/author
  'D/DM/DMAKI/DateTime-Format-Japanese-0.01.tar.gz',

  # meta_yml/requires/version
  'W/WH/WHYNOT/File-AptFetch-0.0.7.tar.gz',

  # meta_yml/version (Module::Build::Version)
  'D/DP/DPRICE/Time-Piece-Adaptive-0.03.tar.gz',
);

my $mirror = setup_mirror(@paths);

my $analyzer = WWW::CPANTS::Analyze->new;
for my $path (@paths) {
  my $context = $analyzer->analyze(dist => $mirror->file($path));
  my $json = eval { $context->dump_stash };
  ok !$@, "$path: encoded json without errors";
}

done_testing;
