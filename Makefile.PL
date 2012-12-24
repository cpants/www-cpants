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
    'CLI::Dispatch' => '0.15',
    'DBI' => '1.609',
    'DBD::SQLite' => '1.37',
    'Time::Piece' => '1.16', # tz issue
    'Path::Extended' => '0.21', # better error message
    'CPAN::DistnameInfo' => 0,
    'Exporter::Lite' => 0,
    'File::Temp' => 0,
    'File::HomeDir' => 0,
    'Log::Handler' => 0,
    'JSON::XS' => 0,
    'Digest::MD5' => 0,
    'List::Util' => 0,
    'List::MoreUtils' => 0,
    'File::Spec' => 0,
    'Mojolicious' => '3.65',
    'Module::CoreList' => '2.78', # should always use the latest
    'Module::Find' => 0,
    'String::CamelCase' => 0,
    'String::Random' => 0,
    'Sub::Install' => 0,
    'Timer::Simple' => 0,
    'CSS::Minifier::XS' => 0,
    'JavaScript::Minifier::XS' => 0,
    'CSS::LESS::Filter' => '0.02',
    'XML::Atom::SimpleFeed' => 0,

    'Parallel::Runner' => 0,  # seems working well
    'Scope::OnExit' => 0,
    'Parallel::ForkManager' => 0,

    # For tests
    'Capture::Tiny' => 0,
    'Test::More'          => '0.88',
    'Test::Differences'   => 0,
    'Test::UseAllModules' => '0.10',

    # Plack Application Management
    'Plack::Builder::Conditionals' => 0,
    'Plack::Middleware::AxsLog' => 0,
    'Plack::Middleware::ReverseProxy' => 0,
    (($^O ne 'MSWin32')
      ? (
          'Plack::Middleware::ServerStatus::Lite' => 0,
          'Starman' => 0,
        )
      : ()
    ),

    # For Kwalitee (Module::CPANTS::Analyse deps)
#    'Archive::Any'              => '0.06',
    'Archive::Any::Lite'        => '0.04',
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

    # requires a tweak not to take too much time to guess
    # 'Software::License'         => '0.003',

    ### License
    'List::MoreUtils'           => '0',
    'Pod::Simple::Checker'      => '2.02',

    ### Manifest
    'Array::Diff'               => '0.04',

    ### MetaYML
    'Test::CPAN::Meta::YAML::Version' => '0.21', # data structure change
    'CPAN::Meta::YAML'                 => 0,

    # YAML::(Any|Syck) is a source of troubles...
    # 'YAML::Any'                 => 0,

    ### Pod
    'Pod::Simple::Checker'      => '2.02',

    ### Repackageable
    'List::MoreUtils'           => '0',

    ### Signature, though highly controversial...
    'File::chdir'               => 0,
    'Module::Signature'         => '0.70', # less warnings

    ### Uses
    'Module::ExtractUse'        => '0.27', # requires the latest
    'Set::Scalar'               => 0,

    # Experimental
    'WorePAN' => 0,
  },
  test => { TESTS => 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t' },
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
