use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Deep qw(cmp_deeply);

fixture {
    my @files = (
        'ISHIGAKI/Test-CPANfile-0.06.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
};

my $model = api_model('V5::Dist::Overview');

my @params = (
    [dist    => { name => 'Test-CPANfile' }],
    [release => { name => 'Test-CPANfile-0.06', pause_id => 'ISHIGAKI' }],
);

for my $param (@params) {
    my ($name, $load_arg) = @$param;
    my $subtest = sub ($load_arg) {
        return sub {
            my $res = $model->load($load_arg);
            cmp_deeply $res => {
                'data' => {
                    'issues' => {
                        'core'         => [],
                        'count'        => 2,
                        'experimental' => [{
                            'defined_in'      => 'Module::CPANTS::Kwalitee::MetaYML',
                            'error'           => undef,
                            'is_experimental' => 1,
                            'name'            => 'meta_yml_has_provides',
                            'remedy'          => 'Add all modules contained in this distribution to the META.yml field \'provides\'. Module::Build or Dist::Zilla::Plugin::MetaProvides do this automatically for you.'
                        }],
                        'extra' => [{
                            'defined_in' => 'Module::CPANTS::Kwalitee::MetaYML',
                            'error'      => undef,
                            'is_extra'   => 1,
                            'name'       => 'meta_yml_declares_perl_version',
                            'remedy'     => 'If you are using Build.PL define the {requires}{perl} = VERSION field. If you are using MakeMaker (Makefile.PL) you should upgrade ExtUtils::MakeMaker to 6.48 and use MIN_PERL_VERSION parameter. Perl::MinimumVersion can help you determine which version of Perl your module needs.'
                        }]
                    },
                    'modules' => [{
                        'abstract' => 'see if cpanfile lists every used modules',
                        'name'     => 'Test::CPANfile',
                        'version'  => '0.06'
                    }],
                    'provides'      => [],
                    'special_files' => [
                        'Changes',
                        'MANIFEST',
                        'META.json',
                        'META.yml',
                        'Makefile.PL',
                        'README',
                        'cpanfile'
                    ] } };
        };
    };
    subtest $name => $subtest->($load_arg);
}

done_testing;
