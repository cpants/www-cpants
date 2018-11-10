requires 'Archive::Any::Lite', '0.06';
requires 'Archive::Tar', '1.98';
requires 'Array::Diff', '0.04';
requires 'CPAN::DistnameInfo', '0.06';
requires 'CPAN::Meta::Validator', '2.133380';
requires 'CPAN::Meta::YAML', '0.008';
requires 'Capture::Tiny';
requires 'Class::Accessor', '0.19';
requires 'Class::Load::XS';
requires 'Const::Fast';
requires 'Cookie::Baker::XS';
requires 'Badge::Simple';
requires 'Data::Binary';
requires 'DBD::SQLite';
requires 'DBI';
requires 'DBIx::TransactionManager';
requires 'Data::Dump';
requires 'Digest::FNV::XS';
requires 'Email::Sender', '1.300028';
requires 'Email::Sender::Simple';
requires 'Email::Sender::Transport::Print';
requires 'Email::Sender::Util';
requires 'Email::Simple';
requires 'File::Find::Object', 'v0.2.1';
requires 'File::Spec';
requires 'File::chdir';
requires 'Gravatar::URL';
requires 'HTML::Entities';
requires 'HTTP::Parser::XS';
requires 'Imager';
requires 'Imager::Filter::RoundedCorner';
requires 'Imager::Font';
requires 'JSON::Diffable';
requires 'JSON::MaybeXS';
requires 'JavaScript::Value::Escape';
requires 'LWP::Protocol::PSGI';
requires 'LWP::Protocol::https';
requires 'LWP::UserAgent';
requires 'List::Util', '1.33';
requires 'Log::Handler';
requires 'Log::Handler::Output::File::Stamper';
requires 'Modern::Perl';
requires 'Module::ExtractUse', '0.33';
requires 'Module::Find';
requires 'Module::Pluggable', '2.96';
requires 'Module::Runtime';
requires 'Module::Signature', '0.83';
requires 'Module::Version';
requires 'Mojo::Template';
requires 'Mojolicious';
requires 'Mojolicious::Controller';
requires 'Mojolicious::Plugin';
requires 'Parallel::Runner';
requires 'Params::Validate';
requires 'Parse::CPAN::Whois';
requires 'Parse::LocalDistribution', '0.18';
requires 'Parse::PMFile', '0.35';
requires 'Path::Tiny';
requires 'Plack::Builder::Conditionals';
requires 'Plack::Middleware::AxsLog';
requires 'Plack::Middleware::ReverseProxy';
requires 'Plack::Middleware::ServerStatus::Lite';
requires 'Pod::Simple::Checker', '2.02';
requires 'Role::Basic';
requires 'Software::License', '0.103012';
requires 'String::CamelCase';
requires 'Syntax::Keyword::Try';
requires 'Text::Balanced';
requires 'Text::Diff';
requires 'Text::Markdown::Hoedown';
requires 'Time::Duration';
requires 'URI';
requires 'URI::QueryParam';
requires 'Unicode::UTF8';
requires 'WorePAN';
requires 'WWW::Form::UrlEncoded::XS';
requires 'XML::Atom::SimpleFeed';
requires 'XML::LibXML';
requires 'version', '0.73';
requires 'JSON::XS';
#requires 'Module::CPANTS::SiteKwalitee'; # https://github.com/cpants/Module-CPANTS-SiteKwalitee
suggests 'Plack::Middleware::ServerStatus::Lite';
suggests 'Starman';

on configure => sub {
    requires 'ExtUtils::MakeMaker::CPANfile';
    requires 'perl', '5.020';
};

on test => sub {
    requires 'Cwd';
    requires 'Test::FailWarnings';
    requires 'Test::More', '0.88';
    requires 'Test::UseAllModules', '0.10';
    requires 'WorePAN', '0.14';
};

on develop => sub {
    requires 'Data::Dump';
    requires 'Hash::Diff';
    requires 'Menlo::CLI::Compat';
    requires 'Modern::Perl';
    requires 'Module::CPANfile';
    requires 'Module::Version';
    requires 'Path::Extended::Tiny';
    requires 'Path::Tiny';
    requires 'Perl::PrereqScanner::NotQuiteLite::App';
    suggests 'Test::Pod', '1.18';
    suggests 'Test::Pod::Coverage', '1.04';
};
