package WWW::CPANTS::Test::Fixture;

use Mojo::Base -strict, -signatures;
use WWW::CPANTS::DB;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Util::Path;
use File::Path qw/mkpath/;
use File::stat qw/stat/;
use Exporter qw/import/;

our @EXPORT = qw( fixture );

sub _fixture_id ($caller_file) {
    my $app_root = WWW::CPANTS->instance->app_root;
    my $path     = Path::Tiny::path($caller_file)->relative($app_root);
    $path =~ s/\.t$//;
    $path =~ s/[^A-Za-z0-9_]+/_/g;
    $path;
}

sub fixture : prototype(&;$) ($code, $id = undef) {
    my ($package, $file, $line) = caller;
    $id //= _fixture_id($file);

    my $json_file = cpants_app_path("tmp/fixture/$id.json");
    if ($json_file->exists and !$ENV{HARNESS_IS_VERBOSE}) {
        if ($json_file->stat->mtime > stat($file)->mtime) {
            _load_fixture($json_file);
            return;
        }
    }
    $code->();
    _save_fixture($json_file);
}

sub _load_fixture ($file) {
    my $fixture = slurp_json($file);
    my $db      = WWW::CPANTS::DB->new;

    if (my $json = delete $fixture->{__json}) {
        for my $file (keys %$json) {
            save_json($file => $json->{$file});
        }
    }

    for my $name (keys %$fixture) {
        my $table = $db->table($name)->setup;
        $table->truncate;
        $table->bulk_insert($fixture->{$name});
    }
}

sub _save_fixture ($file) {
    my %fixture;
    my $json_dir = cpants_path("tmp/json");
    if (-d $json_dir) {
        my $iter = $json_dir->iterator({ recurse => 1 });
        while (my $file = $iter->()) {
            my $path = $file->relative($json_dir);
            $path =~ s/\.json$//;
            next if $path =~ /^Task/;
            my $data = slurp_json($file) or next;
            $fixture{__json}{$path} = $data;
        }
    }

    my $db = WWW::CPANTS::DB->new;
    for my $name ($db->table_names) {
        my $table = $db->table($name);
        next unless $table->is_setup;
        my $rows = $table->dump_me;
        $fixture{$name} = $rows;
    }
    save_json($file, \%fixture);
}

1;
