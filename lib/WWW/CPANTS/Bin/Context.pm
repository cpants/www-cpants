package WWW::CPANTS::Bin::Context;

use WWW::CPANTS;
use parent 'WWW::CPANTS::Context';
use WWW::CPANTS::Bin::Util;
use WWW::CPANTS::Bin::Util::PidFile;
use Getopt::Long ();

my %LoadedTasks;

sub get_options ($self, $default_specs) {
  local @ARGV = @ARGV;

  if (!$self->task_names) {
    my %map;
    for my $module (findallmod 'WWW::CPANTS::Bin::Task') {
      (my $name = $module) =~ s/^WWW::CPANTS::Bin::Task:://;
      $map{$name} = $module;
    }
    my (@task_names, @rest);
    for my $id (0..@ARGV - 1) {
      my $arg = $ARGV[$id];
      if ($map{$arg}) {
        push @task_names, $arg;
        splice @ARGV, $id, 1;
        last;
      }
    }
    if (!@task_names) {
      say "available tasks:";
      for my $name (sort keys %map) {
        my $last_executed = (slurp_json("task/".package_path_name($name)) // {})->{last_executed};
        say " - $name" . ($last_executed ? " [Last executed at: ".strftime('%Y-%m-%d %H:%M:%S', $last_executed)."]" : "");
      }
      return;
    }
    $self->{args}{tasks} = \@task_names;
  }

  my (@specs, %seen_specs);
  for my $name ($self->task_names) {
    my $module = $self->_load_task($name);
    for my $spec ($module->option_specs) {
      (my $spec_name = $spec->[0]) =~ s/\|.+$//;
      next if $seen_specs{$spec_name}++;
      push @specs, $spec;
    }
  }
  push @specs, [], @$default_specs;

  my $parser = Getopt::Long::Parser->new(
    config => [qw/bundling no_ignore_case pass_through/],
  );
  $parser->getoptions(\my %opts => map {$_->[0]} grep {$_->[0]} @specs);
  my @args_for_tasks = @ARGV;
  $self->{task_args} = \@args_for_tasks;

  if ($opts{help}) {
    say 'options:';
    for my $spec (@specs) {
      my ($name, $description) = @$spec;
      if (!$name) {
        say ""; next;
      }
      next if substr($name, 0, 1) eq '_'; # internal only
      $name =~ s/[=\|].+$//;
      say "  $name: $description";
    }
    return;
  }

  $opts{debug} = 1 if $ENV{WWW_CPANTS_DEBUG};

  $self->{opts} = \%opts;
}

sub task_names ($self) { @{$self->{args}{tasks} // []} }

sub task ($self, $name) { $self->_load_task($name)->new($self) }

sub _load_task ($self, $name) {
  $LoadedTasks{$name} //= do {
    my $module = "WWW::CPANTS::Bin::Task::".$name;
    use_module($module) or croak $@;
    $module;
  };
}

sub save_pidfile ($self) {
  WWW::CPANTS::Bin::Util::PidFile->new($self->name, $self->{opts}{force});
}

sub cpants_revision ($self) {
  $self->{cpants_revision} //= do {
    my $revision = slurp_json('etc/revision.json') or return 0;
    $revision->{_id};
  };
}

1;
