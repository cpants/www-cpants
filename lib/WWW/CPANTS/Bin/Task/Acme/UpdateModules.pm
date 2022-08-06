package WWW::CPANTS::Bin::Task::Acme::UpdateModules;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use Menlo::CLI::Compat;
use WWW::CPANTS::Util::Loader;
use WWW::CPANTS::Util::Path;
use WWW::CPANTS::Model::TempDir;
use Parse::PMFile;
use File::stat;
use Syntax::Keyword::Try;

our @READ  = qw/AcmeModules/;
our @WRITE = qw/AcmeAuthors AcmeModules/;

our $IGNORE_RE = qr/\b(?:Not|Utils|Register|You|Search|Factory)\b/;

has 'acme_lib' => \&_build_acme_lib;
has 'tmp_root' => \&_build_tmp_root;

sub _build_acme_lib ($self) {
    WWW::CPANTS->instance->app_root->child("tmp/acme_lib");
}

sub _build_tmp_root ($self) {
    WWW::CPANTS->instance->root->child("tmp/acme_tmp");
}

my %fixes = (
    'Acme::CPANAuthors::Austrian'                   => ["1.13181", "1.131810"],
    'Acme::CPANAuthors::Acme::CPANAuthors::Authors' => ["v1.0.0",  "1.000000"],
    'Acme::CPANAuthors::AnyEvent'                   => ["0.07",    "0.05"],
);

sub run ($self, @args) {
    return if WWW::CPANTS->is_testing && !$ENV{TEST_ACME_MODULES};

    $self->_get_installed_acme_lib_versions;

    $self->_install_acme_modules;

    $self->tmp_root->remove_tree;
}

sub _get_installed_acme_lib_versions ($self) {
    my %files;
    my $acme_lib = $self->acme_lib;
    my $iter     = $acme_lib->iterator({ recurse => 1 });
    while (my $file = $iter->()) {
        next if -d $file;
        next if $file =~ /$IGNORE_RE/;
        my $info = Parse::PMFile->new->parse($file);
        for my $module (keys %$info) {
            my $version = $info->{$module}{version} or next;
            $files{$module} = $version;

            ## unfortunately, some modules have indexing issues
            if (exists $fixes{$module} and $fixes{$module}[0] eq $version) {
                $files{$module} = $fixes{$module}[1];
            }
        }
    }
    $self->stash(\%files);
}

sub _install_acme_modules ($self) {
    my $modules_table = $self->db->table('AcmeModules');
    my $authors_table = $self->db->table('AcmeAuthors');
    my $uploads_table = $self->db->table('Uploads');

    my $force = $self->force || !$modules_table->exists || !$authors_table->exists;

    my %seen;
    my $acme_lib = $self->acme_lib;
    local @INC = ("$acme_lib", @INC);
    for my $package ($self->cpan->packages->list->@*) {
        my ($uid, $module, $version) = $package->@{qw/uid module version/};

        next unless $module =~ /^Acme::CPANAuthors::/;
        next if $module     =~ /::$IGNORE_RE/;
        next unless $version;
        $seen{$module}++;

        my $path  = "$module.pm" =~ s!::!/!gr;
        my $file  = $acme_lib->child($path);
        my $mtime = $file->exists ? stat($file)->mtime : 0;

        my $stashed_version = $self->stash->{$module} // '';

        $mtime = 0 if $mtime and $stashed_version and $stashed_version ne $version;

        if (!$mtime) {
            if ($stashed_version) {
                $self->log(info => "Updating $module from $stashed_version to $version");
            } else {
                $self->log(notice => "Installing new Acme::CPANAuthors module: $module ($version)");
            }
            $self->_install_acme_module($module);
        }
        next unless $file->exists;

        if (!$mtime or $force) {
            $self->_load_acme_module($module) or next;
            my $upload   = $uploads_table->select_by_uid($uid);
            my $released = $upload->{released};

            my @authors        = grep { $_ ne '' } keys $module->authors->%*;
            my $num_of_authors = @authors;

            $self->log(info => "Registering $module $version");
            $mtime ||= stat($file)->mtime;

            my $module_id = _acme_module_id($module);
            if ($modules_table->has_module_id($module_id)) {
                $modules_table->update_module($module_id, $module, $version, $released, $num_of_authors, $mtime);
            } else {
                $modules_table->insert_module($module_id, $module, $version, $released, $num_of_authors, $mtime);
            }

            if (my $txn = $authors_table->txn) {
                try {
                    $authors_table->remove_by_module_id($module_id);
                    $authors_table->insert_for_module_id($module_id, \@authors);
                    $txn->commit;
                } catch {
                    my $error = $@;
                    $self->log(error => "Failed to update $module: $error");
                    $txn->rollback;
                }
            }
        }
    }
    for my $row ($modules_table->select_modules->@*) {
        next if $seen{ $row->{module} };
        $authors_table->remove_by_module_id($row->{module_id});
        $modules_table->remove_by_module_id($row->{module_id});
    }
}

sub _acme_module_id {
    my $module = shift;
    $module =~ s/^Acme::CPANAuthors:://;
    $module =~ s/::/_/g;
    lc $module;
}

sub _load_acme_module ($self, $module) {
    try {
        use_module($module);
        return unless $module->can('authors');
    } catch {
        my $error = $@;
        $self->log(error => $error);
        return;
    }
    return 1;
}

sub _install_acme_module ($self, $module) {
    my $tmp_dir  = WWW::CPANTS::Model::TempDir->new(root => $self->tmp_root);
    my $acme_lib = $self->acme_lib;

    my $menlo = Menlo::CLI::Compat->new;
    $menlo->parse_options(
        '-nf',      '-l', "$tmp_dir",
        '--mirror', 'https://cpan.cpanauthors.org',
        $module,
    );
    $menlo->run;

    my $tmp_lib = $tmp_dir->child("lib/perl5");
    my $iter    = $tmp_lib->iterator({ recurse => 1 });
    while (my $file = $iter->()) {
        next unless $file =~ /\.pm$/;
        next unless $file =~ /CPANAuthors/;
        next if $file =~ /$IGNORE_RE/;
        my $rel    = $file->relative($tmp_lib);
        my $target = $acme_lib->child($rel);
        $target->parent->mkpath;
        chmod 0644, $target;
        $file->copy($target);
    }
}

1;
