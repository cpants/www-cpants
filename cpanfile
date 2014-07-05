on 'configure' => sub {
  requires 'ExtUtils::MakeMaker::CPANfile' => '0.04';
};

on 'build' => sub {
  # for cpanm --installdeps .
  requires 'ExtUtils::MakeMaker::CPANfile' => '0.04';
};

# For site/scripts
requires 'CLI::Dispatch' => '0.15';
requires 'CPAN::DistnameInfo' => '0.06'; # CHECK
requires 'DBD::SQLite' => '1.37';
requires 'DBI' => '1.609';
requires 'Digest::MD5' => 0;
requires 'Exporter::Lite' => 0;
requires 'File::HomeDir' => 0;
requires 'File::Spec' => 0;
requires 'File::Temp' => 0;
requires 'HTTP::Tiny' => 0;
requires 'Imager' => 0;
requires 'JSON::XS' => 0;
requires 'List::MoreUtils' => 0;
requires 'List::Util' => 0;
requires 'Log::Handler' => 0;
requires 'Module::CoreList' => '3.09'; # CHECK: should always use the latest
requires 'Module::Find' => 0;
requires 'Mojolicious' => '4.63';
requires 'Parallel::Runner' => 0;  # seems working well
requires 'Parallel::ForkManager' => 0;
requires 'Path::Extended' => '0.21'; # better error message
requires 'Scope::OnExit' => 0;
requires 'String::CamelCase' => 0;
requires 'String::Random' => 0;
requires 'Sub::Install' => 0;
requires 'Text::Markdown::Hoedown' => '0.07';
requires 'Time::Piece' => '1.16'; # tz issue
requires 'Timer::Simple' => 0;
requires 'WorePAN' => '0.09';  # for PAUSEID/Dist convention

# Plack Application Management
requires 'Plack::Builder::Conditionals' => 0;
requires 'Plack::Middleware::AxsLog' => 0;
requires 'Plack::Middleware::ReverseProxy' => 0;
if ($^O ne 'MSWin32') {
  requires 'Plack::Middleware::ServerStatus::Lite' => 0;
  requires 'Starman' => 0;
}

# minifier
requires 'CSS::LESS::Filter' => '0.02';
requires 'CSS::Minifier::XS' => '0.09';
requires 'JavaScript::Minifier::XS' => '0.09';

# feed
requires 'XML::Atom::SimpleFeed' => 0;

# For tests
on 'test' => sub {
  requires 'Capture::Tiny' => 0;
  requires 'Module::CPANfile' => 0;
  requires 'Test::Differences' => 0;
  requires 'Test::More' => '0.88';
  requires 'Test::UseAllModules' => '0.10';
};

# Dependencies for external libs

# For Kwalitee (Module::CPANTS::Analyse deps)
requires 'Archive::Any::Lite' => '0.04'; # CHECK
requires 'Archive::Tar' => '1.98'; # CHECK # for PAX headers
requires 'Archive::Zip' => 0; # CHECK
requires 'Class::Accessor' => '0.19';
requires 'IO::Capture' => '0.05';
requires 'Module::Pluggable' => '0';
requires 'version' => '0.73'; # CHECK
requires 'CPAN::DistnameInfo' => '0.06';

### Kwalitee

### Files
requires 'File::Find::Rule::VCS' => '0';
requires 'File::Slurp' => '0';

### License
# requires a tweak not to take too much time to guess
requires 'Software::License' => '0.103008'; # CHECK
requires 'Software::License::CC_BY_SA_3_0' => '0';

### Manifest
requires 'Array::Diff' => '0.04';
requires 'ExtUtils::Manifest' => 0;

### MetaYML
requires 'CPAN::Meta::YAML' => 0; # CHECK
requires 'CPAN::Meta::Validator' => '2.133380'; # CHECK

### Uses
requires 'Module::ExtractUse' => '0.33'; # CHECK: no support
requires 'Set::Scalar' => 0;

### SiteKwalitee

### Pod
requires 'Pod::Simple::Checker' => '2.02'; # CHECK

### Signature; though highly controversial...
requires 'File::chdir' => 0;
requires 'Module::Signature' => '0.70'; # CHECK: less warnings

### Version
requires 'Parse::LocalDistribution' => '0.09'; # CHECK
requires 'Parse::PMFile' => '0.16'; # CHECK
