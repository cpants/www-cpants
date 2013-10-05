use strict;
use warnings;
use Test::More;
use WWW::CPANTS::AppRoot;
use Module::ExtractUse;
use Module::CPANfile;
use Module::CoreList;

my $libdir = appdir('lib');
my $tdir   = appdir('t');

my %alias = (
  'CLI::Dispatch::Command' => 'CLI::Dispatch',
  'Furl::HTTP' => 'Furl',
  'Imager::Font' => 'Imager',
  'IO::Capture::Stderr' => 'IO::Capture',
  'IO::Capture::Stdout' => 'IO::Capture',
  'Mojo::Template' => 'Mojolicious',
  'Path::Extended::File' => 'Path::Extended',
  'Path::Extended::Dir' => 'Path::Extended',
  'Test::Mojo' => 'Mojolicious',
);
my %extlibs = map {$_ => 1} qw(Module::CPANTS::SiteKwalitee);

my $cpanfile = Module::CPANfile->load(appfile('cpanfile'));
my %requires = %{ $cpanfile->prereq_specs };
my %provides;
$libdir->recurse(callback => sub {
  my $file = shift;
  my $path = $file->relative($libdir);
  return unless $path =~ /\.pm$/;
  (my $package = $path) =~ s!/!::!g;
  $package =~ s/\.pm$//;
  $provides{$package} = $path;
});

for my $path (values %provides) {
  next if $path eq 'WWW/CPANTS/Test.pm'; # used only in tests

  my $file = $libdir->file($path);
  my $p = Module::ExtractUse->new;
  $p->extract_use("$file");
  my @used = $p->array_out_of_eval;
  my @missing =
    grep {!Module::CoreList::first_release($_)}
    grep {!exists $requires{runtime}{requires}{$_}}
    grep {!exists $provides{$_}}
    grep {!exists $extlibs{$_}}
    map { $alias{$_} || $_ }
    @used;
  ok !@missing, "$path";
  note "$path misses @missing" if @missing;
}

$tdir->recurse(callback => sub {
  my $file = shift;
  return unless $file =~ /\.t$/;
  my $path = $file->relative($tdir);
  my $p = Module::ExtractUse->new;
  $p->extract_use("$file");
  my @used = $p->array_out_of_eval;
  my @missing =
    grep {!Module::CoreList::first_release($_)}
    grep {!exists $requires{test}{requires}{$_}}
    grep {!exists $requires{runtime}{requires}{$_}}
    grep {!exists $provides{$_}}
    grep {!exists $extlibs{$_}}
    map { $alias{$_} || $_ }
    @used;
  ok !@missing, "$path";
  note "$path misses @missing" if @missing;
});

done_testing;
