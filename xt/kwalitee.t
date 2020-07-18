use Mojo::Base -strict, -signatures;
use Test::More;
use WWW::CPANTS::Model::Kwalitee;
use WWW::CPANTS::Util::Path;

my $model = WWW::CPANTS::Model::Kwalitee->new;
my $t_dir = cpants_app_path("t/kwalitee");
my %seen;

subtest 'all tests exist' => sub {
    for my $name (sort $model->names->@*) {
        my $path = "$name.t";
        $seen{$path}++;
        my $file = $t_dir->child($path);
        ok -f $file, "$path exists";
    }
};

subtest 'all removed tests are removed' => sub {
    for my $name (sort map { $_->basename } $t_dir->children) {
        ok exists $seen{$name}, "$name exists";
    }
};

done_testing;
