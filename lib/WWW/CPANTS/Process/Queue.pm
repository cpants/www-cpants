package WWW::CPANTS::Process::Queue;

use strict;
use warnings;
use WWW::CPANTS::DB::Queue;
use WWW::CPANTS::Log;
use Path::Extended;

sub new {
  my ($class, %args) = @_;
  WWW::CPANTS::DB::Queue->new->setup;
  bless \%args, $class;
}

sub enqueue_cpan {
  my ($self, %args) = @_;
  my $cpan = $args{cpan} || $self->{cpan} or die "requires a CPAN mirror";
  my $dir = dir($cpan)->subdir('authors/id');
  die "$dir seems not a CPAN mirror" unless $dir->exists;

  my $pm;
  if (my $workers = $args{workers} || $self->{workers}) {
    require WWW::CPANTS::ForkManager;
    $pm = WWW::CPANTS::ForkManager->new(
      max_workers => $workers,
      on_child_reap => sub {
        my ($pid, $exit, $id) = @_;
        $self->log(debug => "finished (pid: $pid exit: $exit)");
      },
    );
  }

  for my $child ($dir->children) {
    next unless $child->is_dir;
    next if -l $child->path;
    $pm and $pm->start and next;
    $self->log(debug => "searching " . $child->basename);

    my $queue = WWW::CPANTS::DB::Queue->new(%args);
    my @paths;

    $child->recurse(prune => 1, depthfirst => 1, callback => sub {
      my $e = shift;
      return if -d $e;
      return if -l $e;

      my $basename = $e->basename;
      my $relpath = $e->relative($dir);

      # ignore old scripts
      return unless $relpath =~ m{^[A-Z]/[A-Z][A-Z]/};

      # ignore meta files
      return if $basename eq 'CHECKSUMS';
      return if $basename =~ /\.(?:readme|meta)$/i;

      # ignore non-archives
      return unless $basename =~ /\.(?:tar\.(gz|bz2)|tgz|zip)$/i;

      # ignore ppm archives
      return if $basename =~ /\.ppm\.(?:tar\.gz|zip)$/i;

      # ignore large language distributions
      return if $basename =~ /^perl5?[-_]\d/;
      return if $basename =~ /^ponie-/;
      return if $basename =~ /^parrot-/;
      return if $basename =~ /^kurila-/;
      return if $basename =~ /^Perl6-Pugs/;

      # ignore Bundle/Task distributions too?
      # return if $basename =~ /^(?:Task|Bundle)-/;

      push @paths, [$relpath];

      if (@paths > 100) {
        $queue->enqueue(\@paths);
        @paths = ();
      }
    });
    if (@paths) {
      $queue->enqueue(\@paths);
    }
    $pm and $pm->finish(0);
  }
  $pm and $pm->wait_all_children;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Queue

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
