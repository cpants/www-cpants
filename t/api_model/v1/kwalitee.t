use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Deep qw(cmp_deeply re);

fixture {
    my @files = (
        'ISHIGAKI/Path-Extended-0.19.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    load_task('UpdateCPANIndices::Whois')->run;
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
    load_task('PostProcess::UpdateAuthorStats')->run;
    load_task('PostProcess::UpdateRanking')->run;
};

my $model = api_model('V1::Kwalitee');

subtest 'mine' => sub {
    my $res = $model->load({pause_id => 'ISHIGAKI'});

    cmp_deeply $res => {
        info => {
            Average_Kwalitee => re('[0-9]+\.[0-9]+'),
            CPANTS_Game_Kwalitee => '100',
            Liga => 'less than 5',
            Rank => 1,
        },
        distributions => {
            'Path-Extended' => {
                details => {
                    buildtool_not_executable => 'ok',
                    configure_prereq_matches_use => 'ok',
                    consistent_version => 'ok',
                    distname_matches_name_in_meta => 'ok',
                    extractable => 'ok',
                    extracts_nicely => 'ok',
                    has_abstract_in_pod => 'ok',
                    has_buildtool => 'ok',
                    has_changelog => 'ok',
                    has_contributing_doc => 'opt_not_ok',
                    has_human_readable_license => 'ok',
                    has_known_license_in_source_file => 'ok',
                    has_license_in_source_file => 'ok',
                    has_manifest => 'ok',
                    has_meta_json => 'opt_not_ok',
                    has_meta_yml => 'ok',
                    has_proper_version => 'ok',
                    has_readme => 'ok',
                    has_security_doc => 'opt_not_ok',
                    has_separate_license_file => 'opt_not_ok',
                    has_tests => 'ok',
                    has_tests_in_t_dir => 'ok',
                    has_version => 'ok',
                    main_module_version_matches_dist_version => 'ok',
                    manifest_matches_dist => 'ok',
                    meta_json_conforms_to_known_spec => 'ok',
                    meta_json_is_parsable => 'ok',
                    meta_yml_conforms_to_known_spec => 'ok',
                    meta_yml_declares_perl_version => 'opt_not_ok',
                    meta_yml_has_license => 'ok',
                    meta_yml_has_provides => 'opt_not_ok',
                    meta_yml_has_repository_resource => 'opt_not_ok',
                    meta_yml_is_parsable => 'ok',
                    no_abstract_stub_in_pod => 'ok',
                    no_broken_auto_install => 'ok',
                    no_broken_module_install => 'ok',
                    no_dot_dirs => 'ok',
                    no_dot_underscore_files => 'ok',
                    no_files_to_be_skipped => 'ok',
                    no_generated_files => 'ok',
                    no_invalid_versions => 'ok',
                    no_local_dirs => 'ok',
                    no_maniskip_error => 'ok',
                    no_missing_files_in_provides => 'ok',
                    no_mymeta_files => 'ok',
                    no_pax_headers => 'ok',
                    no_pod_errors => 'ok',
                    no_stdin_for_prompting => 'ok',
                    no_symlinks => 'ok',
                    no_unauthorized_packages => 'ok',
                    portable_filenames => 'ok',
                    prereq_matches_use => 'ok',
                    proper_libs => 'ok',
                    security_doc_contains_contact => 'opt_not_ok',
                    test_prereq_matches_use => 'ok',
                    use_strict => 'ok',
                    use_warnings => 'ok',
                    valid_signature => 'ok'
                },
                kwalitee => re('[0-9]+\.[0-9]+'),
            },
        },
    };
};

done_testing;
