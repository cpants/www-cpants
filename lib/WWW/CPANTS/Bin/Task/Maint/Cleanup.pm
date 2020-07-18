package WWW::CPANTS::Bin::Task::Maint::Cleanup;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::Datetime;
use WWW::CPANTS;
use Syntax::Keyword::Try;

sub run ($self, @args) {
    my $app_root = WWW::CPANTS->instance->app_root;

    for my $target (qw/analyze test/) {
        my $tmp_dir = $app_root->child("tmp/$target");
        next unless -d $tmp_dir;

        for my $dir ($tmp_dir->children) {
            my $path = $dir->relative($app_root);
            if ($dir->stat->mtime < days_ago(1)->epoch) {
                try {
                    $dir->remove_tree({ safe => 0 });
                    $self->log(info => "Remove $path");
                } catch {
                    $self->log(error => "Failed to remove $path: $@");
                };
            }
        }
    }
}

1;
