use strict;
use warnings;
use CPAN::DistnameInfo;
use WWW::CPANTS::Extlib;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Analyze;
use WWW::CPANTS::Process::Uploads;
use WWW::CPANTS::Process::CPAN;
use WWW::CPANTS::Process::Queue;
use WWW::CPANTS::Process::Analysis;
use WWW::CPANTS::Process::Kwalitee;

my @tests = (
  [ # a test module in t/lib, evaled build prereqs
    ['ISHIGAKI/Acme-CPANAuthors-0.20.tar.gz', 1],
    ['ISHIGAKI/Test-UseAllModules-0.14.tar.gz'],
    ['GBARR/CPAN-DistnameInfo-0.12.tar.gz'],
    ['KASEI/Class-Accessor-0.34.tar.gz'],
    ['MSCHWERN/Gravatar-URL-1.06.tar.gz'],
    ['DWHEELER/Test-Pod-1.48.tar.gz'],
    ['PETDANCE/Test-Pod-Coverage-1.08.tar.gz'],
    ['GAAS/libwww-perl-6.05.tar.gz'],
    ['CRENZ/Module-Find-0.11.tar.gz'],
    ['MAKAMAKA/JSON-2.57.tar.gz'],
    ['DOY/Try-Tiny-0.12.tar.gz'],
  ],
  [
    ['ETHER/Dist-Zilla-Plugin-Test-CleanNamespaces-0.004.tar.gz', 1],
    ['RJBS/Dist-Zilla-5.019.tar.gz'],
    ['ETHER/Moose-2.1209.tar.gz'],
    ['DAGOLDEN/MooseX-Types-Stringlike-0.003.tar.gz'],
    ['DAGOLDEN/Path-Tiny-0.054.tar.gz'],
    ['ETHER/namespace-autoclean-0.19.tar.gz'],
  ],
);

for my $test (@tests) {
  my $mirror = setup_mirror(map {$_->[0]} @$test);
  my $root = $mirror->root->path;
  my $path = $test->[0][0];
  my $distv = CPAN::DistnameInfo->new($path)->distvname;

  my $tarball = $mirror->file($path);

  note "updating uploads database";
  WWW::CPANTS::Process::Uploads->new->update(
    cpan => $root,
    backpan => $root,
  );

  note "updating CPAN database";
  WWW::CPANTS::Process::CPAN->new->update(cpan => $root);

  note "enqueue";
  WWW::CPANTS::Process::Queue->new->enqueue_cpan(cpan => $root);

  note "analyze";
  WWW::CPANTS::Process::Analysis->new->process_queue(cpan => $root);

  note "updating kwalitee databases";
  WWW::CPANTS::Process::Kwalitee->new->update(qw/
    IsCPAN
    LatestDists
    PrereqDist
    UsedModuleDist
    PrereqMatchesUse
  /);

  my $row = db('Kwalitee')->fetch_distv($distv);
  my $result = $row->{prereq_matches_use};
  is $result => $test->[0][1], "$distv: prereq_mathes_use: $result";
  note explain $row;

  note explain decode_json(db('Analysis')->fetch_json_by_id($row->{analysis_id}));
  note explain db('Errors')->fetch_distv_errors($distv);
  note explain db('PrereqModules')->fetch_prereqs_of($distv);
  note explain db('UsedModules')->fetch_used_modules_of($distv);
}

done_testing;
