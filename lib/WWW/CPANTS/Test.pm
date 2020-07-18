package WWW::CPANTS::Test;

use Mojo::Base -strict, -signatures;
use WWW::CPANTS;
use WWW::CPANTS::Util::Distname;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Util::Loader;
use WWW::CPANTS::Util::Path;
use WWW::CPANTS::Util::PathUid;
use WWW::CPANTS::Test::TestPAN;
use Exporter ();
use Test::More;
use Test::Deep qw(cmp_deeply);

our @EXPORT = @Test::More::EXPORT;
push @EXPORT, qw(
    load_task
    setup_testpan
    test_kwalitee test_analysis
    api_model
);

$ENV{EMAIL_SENDER_TRANSPORT} = 'Test';

sub import ($class) {
    if (my $dsn = $ENV{PERL_TEST_MYSQLPOOL_DSN}) {
        require DBI;
        my $dbh = DBI->connect($dsn);

        my $database = join '', 'cpants', $$, time;
        $dbh->do("CREATE DATABASE $database");
        $dsn =~ s/dbname=test/dbname=$database/;

        WWW::CPANTS->instance->merge_config({
            db => {
                handle_class => 'MySQL',
                MySQL        => {
                    dsn => $dsn,
                },
            },
        });
    }
    goto &Exporter::import;
}

sub setup_testpan (@files) {
    WWW::CPANTS::Test::TestPAN->new->setup(@files);
}

sub load_task ($name) {
    require WWW::CPANTS::Bin::Runner;
    my $runner = WWW::CPANTS::Bin::Runner->new;
    my $task   = $runner->ctx->load_task($name);
    $task->setup_tables;
    $task;
}

sub test_analysis ($selector, @tests) {
    my $testpan = setup_testpan(map { $_->[0] } @tests);

    my $task = load_task('Analyze');

    require Mojo::JSON::Pointer;
    for my $test (@tests) {
        my $path  = valid_distinfo($test->[0])->{path};
        my $uid   = path_uid($path);
        my $stash = $task->analyze_file($testpan->distribution($path));

        $task->run_subtasks($uid, $stash);

        my $result = get_partial_json_data($stash, $selector);
        cmp_deeply $result => $test->[1],
            $test->[0] . " $selector: " . (ref $result ? encode_pretty_json($result) : encode_json($result))
            or note explain $stash;

        if ($test->[2]) {
            if (ref $test->[2] eq ref sub { }) {
                $test->[2]->($stash);
            } else {
                note explain $stash;
            }
        }
    }
}

sub test_kwalitee ($name, @tests) {
    test_analysis("/kwalitee/$name", @tests);
}

sub api_model ($name) {
    require WWW::CPANTS::API::Context;
    my $ctx   = WWW::CPANTS::API::Context->new;
    my $model = use_module("WWW::CPANTS::API::Model::$name");
    $model->new(ctx => $ctx);
}

1;
