package WWW::CPANTS::Bin::Runner;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use WWW::CPANTS::Bin::Context;

my @DefaultSpecs = (
  ['db_type|db-type=s', 'database type (default: SQLite)'],
  ['db_base|db-base=s', 'database dir/id (default: db)'],
  [],
  ['cpan_dir|cpan-dir=s', 'cpan directory'],
  ['backpan_dir|backpan-dir=s', 'backpan directory'],
  [],
  ['help|h|?', 'show options'],
  ['verbose|v', 'show more messages'],
  ['debug', 'show debugging messages'],
  ['force|f', 'run ignoring existing pidfile'],
  ['mode=s', 'run mode'],
);

sub run ($class, %args) {
  my $bin_path = (caller)[1];
  my $name = Path::Tiny::path($bin_path)->relative(app_dir('bin'))->stringify;

  my $ctx = WWW::CPANTS::Bin::Context->new($name, %args);
  local $WWW::CPANTS::CONTEXT = $ctx;

  $ctx->get_options(\@DefaultSpecs) or exit;

  if (under_maintenance() && !$ctx->option('force')) {
    say STDERR "Under maintenance; use --force to run";
    exit;
  }

  $ctx->load_config;
  $ctx->setup_logger;

  my $pidfile = $ctx->save_pidfile;
  my $timer = timer($ctx->name);

  try_and_log_error {
    for my $name ($ctx->task_names) {
      $ctx->task($name)->run_and_log(@{$ctx->{task_args} // []});
    }
  };
}

1;
