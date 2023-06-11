use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::API::Util::Validate;
use WWW::CPANTS::Model::CPAN::Packages;
use Test::More;
use Parse::Distname qw/parse_distname/;

my %fails;
my $packages = WWW::CPANTS::Model::CPAN::Packages->new(root => WWW::CPANTS->instance->root);
for my $package ($packages->list->@*) {
    my $path = $package->{path};
    my $info = parse_distname($path);
    my ($name, $version) = @$info{qw/name version/};
    ok defined(is_path($path)),     "$path is path"                  or $fails{$path}{$path} = 1;
    ok defined(is_alphanum($name)), "$path name ($name) is alphanum" or $fails{$name}{$path} = 1;
    if (defined $version) {
        ok defined(is_alphanum($version)), "$path version ($version) is alphanum" or $fails{$version}{$path} = 1;
    }
}
note explain [map { $_ => [sort keys $fails{$_}->%*] } sort keys %fails];

done_testing;
