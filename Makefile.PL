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
    'Furl' => 0,
    'Log::Handler' => 0,
    'JSON::XS' => 0,
    'Digest::MD5' => 0,
    'Imager' => 0,
    'List::Util' => 0,
    'List::MoreUtils' => 0,
    'File::Spec' => 0,
    'Mojolicious' => '4.00',
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
    'WorePAN' => '0.04',  # for rare ids

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
    'Archive::Any::Lite'        => '0.04',
    'Archive::Tar'              => '1.48',
    'Class::Accessor'           => '0.19',
    'IO::Capture'               => '0.05',
    'Module::Pluggable'         => '0',
    'version'                   => '0.73',
    'CPAN::DistnameInfo'        => '0.06',

    ### Kwalitee::

    ### Files
    'File::Find::Rule::VCS'     => '0',
    'File::Slurp'               => '0',

    ### License
    # requires a tweak not to take too much time to guess
    # 'Software::License'         => '0.003',

    ### Manifest
    'Array::Diff'               => '0.04',

    ### MetaYML
    'CPAN::Meta::YAML'                 => 0,
    'CPAN::Meta::Validator'            => 0,

    ### Uses
    'Module::ExtractUse'        => '0.31', # used_in_eval
    'Set::Scalar'               => 0,

    ### SiteKwalitee::

    ### Pod
    'Pod::Simple::Checker'      => '2.02',

    ### Signature, though highly controversial...
    'File::chdir'               => 0,
    'Module::Signature'         => '0.70', # less warnings

    ### Version
    'Parse::LocalDistribution'  => '0.02',
    'Parse::PMFile'             => '0.04',


    # Experimental
  },
  test => { TESTS => 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t' },
  META_MERGE => {
    resources => {
      repository => 'https://github.com/charsbar/www-cpants',
    },
    no_index => {
      directory => [qw!extlib log test_mirror tmp test_utils xt xutils!],
    },
  },
);

my $eumm = $ExtUtils::MakeMaker::VERSION;
delete $params{META_MERGE} if $eumm < 6.46;
delete $params{LICENSE}    if $eumm < 6.31;

WriteMakefile(%params);
