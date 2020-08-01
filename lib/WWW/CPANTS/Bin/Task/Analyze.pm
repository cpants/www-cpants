package WWW::CPANTS::Bin::Task::Analyze;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::Distname;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Util::PathUid;
use WWW::CPANTS::Util::HideInternal;
use WWW::CPANTS::Model::Archive;
use WWW::CPANTS::Model::Revision;
use Syntax::Keyword::Try;

our @READ    = qw/Analysis/;
our @WRITE   = qw/Analysis/;
our @OPTIONS = (
    'skip_analysis|skip',
    'dump',
    'timeout=i',
    'slow=i',
);

has 'subtasks' => \&_build_subtasks;
has 'revision' => \&_build_revision;

sub _build_subtasks ($self) {
    my @subtasks = map { $self->subtask($_) } qw(
        Analyze::UpdateProvides
        Analyze::UpdateRequiresAndUses
        Analyze::UpdateResources
        Analyze::UpdateKwalitee
        Analyze::UpdateErrors
    );
    \@subtasks;
}

sub _build_revision ($self) {
    WWW::CPANTS::Model::Revision->new->id;
}

sub run ($self, @args) {
    return unless @args;

    for my $path (@args) {
        next unless defined $path and $path ne '';
        my $info = valid_distinfo($path) or next;
        $path = $info->{path} or next;
        my $uid = path_uid($path);
        $self->analyze($uid, $path);
    }
}

sub run_subtasks ($self, $uid, $stash) {
    for my $task ($self->subtasks->@*) {
        $task->update($uid, $stash);
    }
    $stash;
}

sub analyze ($self, $uid, $path) {
    my $table = $self->db->table('Analysis');

    my $previous = $table->select_json_by_uid($uid);
    if ($previous and $self->skip_analysis) {
        return $self->run_subtasks($uid, decode_json($previous));
    }

    my $file = $self->find_archive_file($path) or return 1;

    $self->log(info => "analyzing $path [$$]");

    my $stash = $self->analyze_file($file);

    if (!$stash) {
        $table->mark_ignored($uid);
        $self->log(info => "ignored $path");
        return 1;
    }

    $self->run_subtasks($uid, $stash);

    my $json = hide_internal(encode_json($stash));
    if ($json =~ /=(?:ARRAY|HASH|SCALAR|GLOB)\(/) {
        # known to have Git::Wrapper=HASH(...) in its META files
        unless ($stash->{vname} eq 'Dist-Zilla-Plugin-Git-2.040') {
            $self->log(alert => "JSON exposes something internal: $path: $json");
        }
    }

    if ($previous) {
        my $diff = json_diff($previous, $json);
        $self->log(notice => "analysis diff ($path):\n$diff") if $diff;
    }

    if ($self->dump) {
        say hide_internal(encode_pretty_json($stash));
        return;
    }

    $table->update_analysis({
        uid             => $uid,
        json            => $json,
        cpants_revision => $self->revision,
    });

    return 1;
}

sub find_archive_file ($self, $path) {
    # basically BackPAN should have everything
    my $file = $self->ctx->backpan->distribution($path);
    return $file if -f $file;

    # probably it's too recent and not synched yet
    $file = $self->ctx->cpan->distribution($path);
    return $file if -f $file;

    # possibly CPAN is out of sync, or the path is wrong
    $self->log(info => "$path not found");
    return;
}

sub analyze_file ($self, $file) {
    my $archive = WWW::CPANTS::Model::Archive->new(file => $file);
    return if $archive->should_be_ignored;

    if ($archive->extract && $archive->is_extracted_nicely) {
        my %elapsed;
        my $dist = $archive->path;
        try {
            local $SIG{ALRM} = sub { die "timeout\n" };
            alarm($self->timeout // 0);

            for my $module ($self->ctx->kwalitee->modules->@*) {
                my $kwalitee_module_id = $module =~ s/^Module::CPANTS:://r;
                my $started            = time;
                my @warnings;
                try {
                    local $SIG{__WARN__} = sub { push @warnings, @_ };
                    $module->analyse($archive);
                } catch {
                    my $error = $@;
                    die $error if $error eq "timeout\n";
                    $archive->stash->{error}{$module} = $error;
                    $self->log(error => "$dist: $error");
                }
                $elapsed{$kwalitee_module_id} = time - $started;
                if (@warnings) {
                    my $message = "$module: " . join '', @warnings;
                    $archive->stash->{error}{cpants_warnings} = $message;
                    $self->log(warn => "$dist: $message");
                }
            }
            alarm 0;
        } catch {
            my $error = $@;
            $self->log(warning => "$dist: $error");
            if ($error eq "timeout\n") {
                $archive->stash->{error}{timeout} = 1;
                my $elapsed_str = _stringify_elapsed(\%elapsed);
                $self->log(alert => "$dist: timeout ($elapsed_str)");
            } else {
                $self->log(error => "$dist: $error");
                $archive->stash->{error}{cpants} = $error;
            }
        }

        my $slow = $self->slow // 120;
        if ($slow and grep { $_ > $slow } values %elapsed) {
            my $elapsed_str = _stringify_elapsed(\%elapsed);
            $self->log(alert => "$dist: too slow ($elapsed_str)");
        }

        $self->ctx->kwalitee->set_results($archive->stash);

        delete $archive->stash->{$_} for qw(
            dirs_list files_list ignored_files_list
            files dirs test_files ignored_files_array
        );

        $archive->check_perl_stuff;
    }
    $archive->stash;
}

sub _stringify_elapsed ($elapsed) {
    join ',',
        map  { sprintf "%s:%0.4f", $_, $elapsed->{$_} }
        sort { $elapsed->{$b} <=> $elapsed->{$a} }
        grep { $elapsed->{$_} && $elapsed->{$_} > 0.05 }
        keys %$elapsed;
}

1;
