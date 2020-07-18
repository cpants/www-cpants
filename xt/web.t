use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Util::Loader;
use WWW::CPANTS::Util::Path;
use Test::More;
use String::CamelCase qw/decamelize/;

my @names = submodule_names("WWW::CPANTS::Web::Controller");
my $t_dir = cpants_app_path("t/web");
my %seen;

subtest 'all the tests exists' => sub {
    for my $name (@names) {
        next if $name =~ /Root|Release/;
        my $path = $name =~ s|::|/|gr;
        $path = decamelize($path) . ".t";
        $seen{$path} = 1;
        my $file = $t_dir->child($path);
        ok -f $file, "test for $name exists" or next;
        my $body = $file->slurp;
        ok $body =~ /Test::Mojo->new\('WWW::CPANTS::Web'\);/, "creates a tester for $name";
    }
};

subtest 'all the tests for removed controller are removed' => sub {
    my $iter = $t_dir->iterator({ recurse => 1 });
    while (my $file = $iter->()) {
        next if -d $file;
        my $path        = $file->relative($t_dir);
        my $parent_path = $file->parent->relative($t_dir) . ".t";
        ok exists $seen{$path} || exists $seen{$parent_path}, "test for $path exists";
    }
};

done_testing;
