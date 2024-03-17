use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Deep qw(cmp_deeply re any array_each subhashof);

$ENV{TEST_ACME_MODULES} = 1;

fixture {
    my @files = (
        'ISHIGAKI/Acme-CPANAuthors-Japanese-0.190426.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    $testpan->cpan->update_indices;

    load_task('UpdateCPANIndices::Whois')->run;
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
    load_task('PostProcess::UpdateAuthorStats')->run;
    load_task('PostProcess::UpdateRanking')->run;
    load_task('Acme::UpdateModules')->run;
    load_task('Acme::UpdateStats')->run;
};

my $model = api_model('Acme::CPANAuthors::Modules');

subtest 'list' => sub {
    my $res = $model->load({});
    cmp_deeply $res => {
        data => array_each(subhashof({
            'active_authors'        => re('[0-9]+'),
            'authors'               => re('[0-9]+'),
            'average_core_kwalitee' => re('[0-9.]+'),
            'average_kwalitee'      => re('[0-9.]+'),
            'distributions'         => re('[0-9.]+'),
            'id'                    => re('\w+'),
            'name'                  => re('^Acme::CPANAuthors::[\w:]+'),
            'new_releases'          => re('[0-9]+'),
            'released'              => re('20[0-9]{2}-[0-9]{2}-[0-9]{2}'),
            'releases'              => re('[0-9]+'),
            'version'               => re('[0-9.]+'),
        })),
        recordsTotal => re('[1-9][0-9]+'),
    };
};

done_testing;
