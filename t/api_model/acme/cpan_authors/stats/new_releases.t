use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Deep qw(cmp_deeply re any array_each subhashof);

$ENV{TEST_ACME_MODULES} = 1;

fixture {
    my @files = (
        'ISHIGAKI/Acme-CPANAuthors-0.26.tar.gz',
        'ISHIGAKI/Acme-CPANAuthors-Japanese-0.190426.tar.gz',
        'ISHIGAKI/Path-Extended-0.19.tar.gz',
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

my $model = api_model('Acme::CPANAuthors::Stats::NewReleases');

subtest 'japanese' => sub {
    my $res = $model->load({ module_id => 'japanese' });
    cmp_deeply $res => {
        'data' => array_each(subhashof({
            'new_releases' => re('[0-9]+'),
            'year'         => re('20[0-9]+'),
        })),
        'recordsTotal' => re('[0-9]+'),
    };
};

done_testing;
