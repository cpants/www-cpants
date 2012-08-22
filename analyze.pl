use strict;
use warnings;
use lib "lib";

WWW::CPANTS::Script::analyze->run_directly;

package WWW::CPANTS::Script::analyze;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::Analyze;
use WWW::CPANTS::AppRoot;
use WorePAN;

sub _options {qw/no_cleanup capture/}

sub _run {
  my ($self, @paths) = @_;

  my $worepan = WorePAN->new(
    root => appdir('tmp/analyze_once/'),
    files => \@paths,
    cleanup => !$self->{no_cleanup},
    no_network => 0,
    use_backpan => 1,
  );

  for my $path (@paths) {
    my $file = $worepan->file($path);
    die "$file not exists" unless $file->exists;

    my $analyzer = WWW::CPANTS::Analyze->new;

    my $start = time;
    my $context = eval { $analyzer->analyze(dist => $file, no_capture => !$self->{capture}) };
    my $error = $@ ? $@ : '';
    my $end = time;

    print $error ? $error : $context ? $context->dump_stash(1) : 'no context';
    print "\n\nelapsed: " . ($end - $start) . " secs\n";
  }
}
