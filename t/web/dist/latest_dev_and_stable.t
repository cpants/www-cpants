use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Mojo;

fixture {
    my @files = (
        ## A case where the latest is not stable
        'ISHIGAKI/Text-CSV-1.90_01.tar.gz',
        'MAKAMAKA/Text-CSV-1.33.tar.gz',

        ## A case where the latest is not stable and there's no stable
        'ISHIGAKI/Module-CPANTS-Analyse-0.97_11.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    $testpan->cpan->update_indices;

    load_task('UpdateCPANIndices')->run;
    load_task('Traverse')->run(qw/ISHIGAKI MAKAMAKA/);
    load_task('Analyze')->run(@files);
    load_task('PostProcess')->run;
};

subtest "/dist shows the latest stable if there's a newer dev" => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    $t->get_ok("/dist/Text-CSV")->status_is(200);
    $t->text_is('h2' => 'Text-CSV 1.33');
};

subtest "/dist shows the latest dev if there's no stable" => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    $t->get_ok("/dist/Text-CSV")->status_is(200);
    $t->text_is('h2' => 'Text-CSV 1.33');
};

subtest "check /releases" => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');

    $t->get_ok("/release/MAKAMAKA/Text-CSV-1.33")->status_is(200);
    $t->text_is('h2' => 'Text-CSV 1.33');

    $t->get_ok("/release/ISHIGAKI/Text-CSV-1.90_01")->status_is(200);
    $t->text_is('h2' => 'Text-CSV 1.90_01');

    $t->get_ok("/release/ISHIGAKI/Module-CPANTS-Analyse-0.97_11")->status_is(200);
    $t->text_is('h2' => 'Module-CPANTS-Analyse 0.97_11');
};

done_testing;
