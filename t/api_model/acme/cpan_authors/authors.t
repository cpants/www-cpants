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

my $model = api_model('Acme::CPANAuthors::Authors');

subtest 'me' => sub {
    my $res = $model->load({ module_id => 'japanese' });
    cmp_deeply $res => {
        'data' => array_each(subhashof({
            'average_core_kwalitee' => re('[0-9.]+'),
            'average_kwalitee'      => re('[0-9.]+'),
            'distributions'         => re('[0-9]+'),
            'last_analyzed_at'      => any(undef, re('[0-9]+')),
            'last_new_release'      => any(undef, re('[0-9]{4}-[0-9]{2}-[0-9]{2}')),
            'last_release'          => any(undef, re('[0-9]{4}-[0-9]{2}-[0-9]{2}')),
            'name'                  => re('.+'),
            'pause_id'              => re('[A-Z-]{2,9}'),
            'recent_distributions'  => re('[0-9]'),
            'registered'            => re('[0-9]{4}-[0-9]{2}-[0-9]{2}'),
            'deleted'               => re('[0-9]'),
        })),
        'module' => {
            'name'     => 'Acme::CPANAuthors::Japanese',
            'released' => re('20[0-9]{2}-[0-9]{2}-[0-9]{2}'),
            'version'  => '0.220625'
        },
        'recordsTotal' => 666,
    };
};

done_testing;
