use strict;
use warnings;
use ExtUtils::MakeMaker;

my %params = (
  NAME          => 'WWW::CPANTS',
  AUTHOR        => 'Kenichi Ishigaki <ishigaki@cpan.org>',
  VERSION_FROM  => 'lib/WWW/CPANTS.pm',
  ABSTRACT_FROM => 'lib/WWW/CPANTS.pm',
  LICENSE       => 'perl',
  PREREQ_PM     => {

    # Scripts
    'Scope::OnExit' => 0,
    'Parallel::ForkManager' => 0,
    'CLI::Dispatch' => '0.15',
    'DBI' => '1.609',
    'DBD::SQLite' => '1.37',
    'Time::Piece' => 0,
    'Path::Extended' => 0,
    'CPAN::DistnameInfo' => 0,
    'Exporter::Lite' => 0,
    'Log::Handler' => 0,
    'JSON::XS' => 0,
    'Digest::MD5' => 0,

    # For tests
    'Test::More'          => '0.88',
    'Test::UseAllModules' => '0.10',

    # For Kwalitee (Module::CPANTS::Analyse deps)
#    'Archive::Any'              => '0.06',
    'Archive::Any::Lite'        => '0.03',
    'Archive::Tar'              => '1.48',
    'Class::Accessor'           => '0.19',
    'IO::Capture'               => '0.05',
    'Module::Pluggable'         => '0',
    'version'                   => '0.73',

    ### Distname
    'CPAN::DistnameInfo'        => '0.06',

    ### Distros
    'LWP::Simple'               => 0,
    'Text::CSV_XS'              => '0.45',

    ### Files
    'ExtUtils::Manifest'        => 0,
    'File::Find::Rule'          => '0',
    'File::Slurp'               => '0',
    'Readonly'                  => '0',
    'Software::License'         => '0.003',

    ### License
    'List::MoreUtils'           => '0',
    'Pod::Simple::Checker'      => '2.02',

    ### Manifest
    'Array::Diff'               => '0.04',

    ### MetaYML
    'Test::CPAN::Meta::YAML::Version' => '0',
    'YAML::Any'                 => 0,

    ### Pod
    'Pod::Simple::Checker'      => '2.02',

    ### Repackageable
    'List::MoreUtils'           => '0',

    ### Signature
    'File::chdir'               => 0,
    'Module::Signature'         => 0,

    ### Uses
    'Module::ExtractUse'        => '0.18',
    'Set::Scalar'               => 0,

    # Experimental
    'WorePAN' => 0,
  },
  META_MERGE => {
    resources => {
      repository => 'https://github.com/charsbar/www-cpants',
    },
  },
);

my $eumm = $ExtUtils::MakeMaker::VERSION;
delete $params{META_MERGE} if $eumm < 6.46;
delete $params{LICENSE}    if $eumm < 6.31;

WriteMakefile(%params);
