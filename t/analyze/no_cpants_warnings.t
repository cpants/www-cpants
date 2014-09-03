use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @paths = (
  # uuv because of a missing infile
  'GFUJI/Dist-Maker-0.01_01.tar.gz',

  # CPAN::Meta::YAML->errstr deprecation
  'ALEXMASS/InSilicoSpectro-0.9.20.tar.gz',

  # unicode mapping
  'ALEXK/Template-Plugin-TwoStage-0.03.tar.gz',
  'KUERBIS/Term-Choose-1.057.tar.gz',

  # illegal meta spec version
  'TBR/WKHTMLTOPDF-0.02.tar.gz',

  # malformed utf-8 for JSON::PP?
  'MAXS/Palm-MaTirelire-1.12.tar.gz',

  # eval illegal version
  'RPAUL/Gentoo-Probe-1.0.6.tar.gz',

  # readline() on closed filehandle $fh
  # lib/Module/CPANTS/Kwalitee/Files.pm line 160.
  'MTHURN/WWW-Search-Ebay-3.032.tar.gz',
);

my @ignore = (
  # String found where operator expected (in parse_version)
  'DROLSKY/HTML-Mason-1.14.tar.gz',
  'PERRAD/CORBA-XS-0.12.tar.gz',
  'RJBS/Module-Faker-0.010.tar.gz',

  # Array found where operator expected (in parse_version)
  'DMAKI/Gungho-0.09003_04.tar.gz',

  # apparently DOSish no_index entries
  'DAGOLDEN/Class-InsideOut-0.90_01.tar.gz',
);

my $mirror = setup_mirror(@paths);
my $analyzer = WWW::CPANTS::Analyze->new;
for my $path (@paths) {
  my $context = $analyzer->analyze(dist => $mirror->file($path));
  ok $context, "has context";
  ok $context && !$context->stash->{error}{cpants_warnings}, "no cpants_warnings";
  note explain $context->stash->{error};
}

done_testing;
