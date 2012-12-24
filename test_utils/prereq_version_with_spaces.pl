use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use WWW::CPANTS::DB::PrereqModules;
use WWW::CPANTS::DB::Analysis;

my $db = WWW::CPANTS::DB::PrereqModules->new;
my $distvs = $db->fetch_dists_whose_prereq_version_has_spaces;
my $analysis_db = WWW::CPANTS::DB::Analysis->new;

my %paths;
for (@$distvs) {
	my $path = $analysis_db->fetch_path_by_distv($_);
	$paths{$path} = 1;
}

print "$_\n" for sort keys %paths;
