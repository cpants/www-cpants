use Mojo::Base -strict, -signatures;
use Test::More;
use WWW::CPANTS::Util::Loader;
use WWW::CPANTS::Util::Path;
use String::CamelCase qw/decamelize/;

my @names = submodule_names("WWW::CPANTS::API::Model");
my $t_dir = cpants_app_path("t/api_model");
my %seen;

subtest 'all the tests exists' => sub {
    for my $name (@names) {
        next unless $name =~ /::/;
        next if $name     =~ /V5::Release::/;
        my $path = $name =~ s|::|/|gr;
        $path = decamelize($path) . ".t";
        $seen{$path} = 1;
        my $file = $t_dir->child($path);
        ok -f $file, "test for $name exists" or next;
        my $body = $file->slurp;
        ok $body =~ /api_model\('$name'\);/, "contains $name";
    }
};

subtest 'all the tests for removed api are removed' => sub {
    my $iter = $t_dir->iterator({ recurse => 1 });
    while (my $file = $iter->()) {
        next if -d $file;
        my $path = $file->relative($t_dir);
        ok exists $seen{$path}, "api for $path exists";
    }
};

done_testing;
