use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Mojo;

fixture {
    my @files = (
        'ISHIGAKI/JSON-4.02.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    $testpan->cpan->update_indices;

    load_task('UpdateCPANIndices')->run;
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
    load_task('PostProcess')->run;
};

my @paths = qw(
    /dist/JSON
    /release/ISHIGAKI/JSON-4.02
);

subtest 'get' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    for my $path (@paths) {
        $t->get_ok($path)->status_is(200);
        $t->text_is('h2' => 'JSON 4.02');
    }
};

subtest 'get json' => sub {
    my $t         = Test::Mojo->new('WWW::CPANTS::Web');
    my @json_keys = qw/issues modules provides special_files/;

    for my $path (@paths) {
        $t->get_ok("$path.json")->status_is(200);
        $t->json_has("/data/$_") for @json_keys;
    }
};

subtest 'get png' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    for my $path (@paths) {
        $t->get_ok("$path.png")->status_is(200);
        $t->content_type_is('image/png');
    }
};

subtest 'get svg' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    for my $path (@paths) {
        $t->get_ok("$path.svg")->status_is(200);
        $t->content_type_is('image/svg+xml');
    }
};

subtest 'get errors' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    for my $path (@paths) {
        $t->get_ok("$path/errors")->status_is(200);
    }
};

subtest 'get errors.json' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    for my $path (@paths) {
        $t->get_ok("$path/errors.json")->status_is(200);
    }
};

subtest 'get files' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    for my $path (@paths) {
        $t->get_ok("$path/files")->status_is(200);
    }
};

subtest 'get files.json' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    for my $path (@paths) {
        $t->get_ok("$path/files.json")->status_is(200);
    }
};

subtest 'get metadata' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    for my $path (@paths) {
        $t->get_ok("$path/metadata")->status_is(200);
    }
};

subtest 'get metadata.json' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    for my $path (@paths) {
        $t->get_ok("$path/metadata.json")->status_is(200);
    }
};

subtest 'get prereq' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    for my $path (@paths) {
        $t->get_ok("$path/prereq")->status_is(200);
    }
};

subtest 'get prereq.json' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    for my $path (@paths) {
        $t->get_ok("$path/prereq.json")->status_is(200);
    }
};

subtest 'get releases' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    for my $path (@paths) {
        $t->get_ok("$path/releases")->status_is(200);
    }
};

subtest 'get releases.json' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    for my $path (@paths) {
        $t->get_ok("$path/releases.json")->status_is(200);
    }
};

subtest 'get used_by' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    for my $path (@paths) {
        $t->get_ok("$path/used_by")->status_is(200);
    }
};

subtest 'get used_by.json' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    for my $path (@paths) {
        $t->get_ok("$path/used_by.json")->status_is(200);
    }
};

done_testing;
