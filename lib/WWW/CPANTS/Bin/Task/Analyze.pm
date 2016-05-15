package WWW::CPANTS::Bin::Task::Analyze;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use WWW::CPANTS::Util::Kwalitee;
use parent 'WWW::CPANTS::Bin::Task';

sub option_specs {(
  ['skip_analysis|skip-anlysis|skip', 'update only subordinate tables'],
  ['show_diff|show-diff|diff', 'show diff'],
  ['dump', 'dump stash'],
)}

sub run ($self, @args) {
  return unless @args;

  my $cpan = $self->cpan;
  $cpan->fetch_permissions unless $cpan->has_permissions;

  $self->setup;
  for my $path (@args) {
    my $uid = path_uid($path);
    if (!$self->option('skip_analysis')) {
      $self->analyze($uid, $path);
    } else {
      my $previous = $self->{table}->select_json_by_uid($uid);
      if (!$previous) {
        $self->analyze($uid, $path);
      } else {
        my $stash = decode_json($previous);
        for my $subtask (@{$self->{subtasks}}) {
          $subtask->run($uid, $stash);
        }
      }
    }
  }
}

sub setup ($self, $db = undef) {
  $self->{db} = $db //= $self->db;
  $self->{table} = $db->table('Analysis');
  $self->{uploads} = $db->table('Uploads');
  $self->{cpants_revision} = $self->{ctx}->cpants_revision;

  my @subtasks = map {$self->task($_)->setup($db)} qw/
    Analyze::UpdateProvides
    Analyze::UpdateRequiresAndUses
    Analyze::UpdateResources
    Analyze::UpdateKwalitee
    Analyze::UpdateErrors
  /;
  $self->{subtasks} = \@subtasks;

  $self;
}

sub analyze ($self, $uid, $path) {
  my $previous = $self->{table}->select_json_by_uid($uid);
  my $file = $self->backpan->child("authors/id/$path");
  if (!-f $file) { # probably it's too recent and not synched yet
    $file = $self->cpan->child("authors/id/$path");
    if (!-f $file) { # not even (just uploaded, or CPAN is out of sync)
      log(info => "$path not found");
      return;
    }
  }
  log(info => "analyzing $path [$$]");
  my $archive = $self->analyze_file($file);

  if (!$archive) {
    $self->{uploads}->mark_ignored($uid);
    log(info => "ignored $path");
    return;
  }

  if ($self->option('dump')) {
    say $archive->dump_stash('pretty');
    return;
  }

  my $json = $archive->dump_stash;
  log(error => "JSON exposes something internal: $path: $json") if $json =~ /=(?:ARRAY|HASH|SCALAR)\(/;
  if ($previous) {
    if ($self->option('show_diff')) {
      my $diff = diff_json($previous, $json);
      log(warn => "analysis diff ($path):\n$diff") if $diff;
    }
  }

  $self->{table}->update_analysis({
    uid => $uid,
    json => $json,
  });
  $self->{uploads}->mark_analyzed($uid, $self->{cpants_revision});

  my $stash = $archive->stash;
  for my $subtask (@{$self->{subtasks}}) {
    $subtask->update($uid, $stash);
  }

  $archive;
}

sub analyze_file ($self, $file) {
  if (!-f $file) {
    log(error => "$file not found");
    return;
  }
  my $archive = $self->model('Archive', $file);
  return if $archive->should_be_ignored;
  if ($archive->extract && $archive->is_extracted_nicely) {
    my %elapsed;
    my $dist = $archive->dist;
    try {
      local $SIG{ALRM} = sub { die "timeout\n" };
      alarm($archive->{timeout} // 0);

      for my $module (@{kwalitee_modules()}) {
        my $started = time;
        my @warnings;
        try {
          local $SIG{__WARN__} = sub { push @warnings, @_ };
          $module->analyse($archive);
        } catch {
          my $error = $_;
          die $error if $error eq "timeout\n";
          $archive->set_error($module => $error);
          log(error => "$dist: $error");
        };
        $elapsed{$module} = time - $started;
        if (@warnings) {
          my $message = "$module: ".join '', @warnings;
          $archive->set_error(cpants_warnings => $message);
          log(warn => "$dist: $message");
        };
      }
      alarm 0;
    } catch {
      my $error = $_;
      log(warning => "$dist: $error");
      if ($error eq "timeout\n") {
        $archive->set_error(timeout => 1);
        my $elapsed_str =
          join ',',
          map {"$_: $elapsed{$_}"}
          sort {$elapsed{$b} <=> $elapsed{$a}}
          grep {$elapsed{$_}}
          keys %elapsed;
        log(error => "$dist: timeout ($elapsed_str)");
      } else {
        log(error => "$dist: $error");
        $archive->set_error(cpants => $error);
      }
    };
    delete $archive->stash->{$_} for qw/
      dirs_list files_list ignored_files_list
      files dirs test_files ignored_files_array
    /;
    $archive->check_perl_stuff;
    $archive->calc_kwalitee;
  }
  $archive;
}

1;
