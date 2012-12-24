use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use WWW::CPANTS::DB::PrereqModules;
use WWW::CPANTS::DB::Analysis;

my $db = WWW::CPANTS::DB::PrereqModules->new;
my $distvs = $db->fetch_dists_whose_prereq_has_spaces;
my $analysis_db = WWW::CPANTS::DB::Analysis->new;

my @paths;
for (@$distvs) {
	push @paths, $analysis_db->fetch_path_by_distv($_);
}

print "$_\n" for @paths;
