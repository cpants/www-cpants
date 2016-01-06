package WWW::CPANTS::Process::Queue;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Log;
use WWW::CPANTS::Util::Parallel;
use WWW::CPANTS::Util::JSON;
use Path::Extended;

sub new {
  my ($class, %args) = @_;
  bless \%args, $class;
}

sub enqueue_cpan {
  my ($self, %args) = @_;
  my $cpan = $args{cpan} || $self->{backpan} || $self->{cpan}
    or die "requires a CPAN mirror";
  my $dir = dir($cpan)->subdir('authors/id');
  die "$dir seems not a CPAN mirror" unless $dir->exists;

  my $pm = WWW::CPANTS::Util::Parallel->new(
    max_workers => $args{workers} || $self->{workers},
  );

  db('Queue')->setup;

  for my $child ($dir->children) {
    next unless $child->is_dir;
    next if -l $child->path;
    $pm->run(sub {
      $self->log(debug => "searching " . $child->basename);

      my $queue = db('Queue');

      $child->recurse(prune => 1, depthfirst => 1, callback => sub {
        my $e = shift;
        return if -d $e;
        return if -l $e;

        my $basename = $e->basename;
        my $relpath = $e->relative($dir);

        # ignore old scripts
        return unless $relpath =~ m{^[A-Z]/[A-Z][A-Z]/};

        # ignore Perl6 subdir
        return if $path =~ m{^[A-Z]/[^/]+/[^/]+/Perl6/};

        # ignore meta files
        return if $basename eq 'CHECKSUMS';
        return if $basename =~ /\.(?:readme|meta)$/i;

        # ignore non-archives
        return unless $basename =~ /\.(?:tar\.(gz|bz2)|tgz|zip)$/i;

        # ignore ppm archives
        return if $basename =~ /\.ppm\.(?:tar\.gz|zip)$/i;

        # ignore large language distributions
        return if $basename =~ /^perl5?[-_]\d/;
        return if $basename =~ /^ponie\-/;
        return if $basename =~ /^parrot\-/;
        return if $basename =~ /^kurila\-/;
        return if $basename =~ /^Perl6\-Pugs/;
        return if $basename =~ /^Rakudo\-Star/;

        # ignore apparently broken distributions
        # e.g. (MARCEL|RENEEB|APEIRON)/-0.01.tar.gz
        return if $basename =~ /^[^a-zA-Z0-9]/;

        # ignore Bundle/Task distributions too?
        # (should ignore at least Bundle::Everything)
        return if $basename =~ /^Bundle\-Everything/;
        # return if $basename =~ /^(?:Task|Bundle)-/;

        my $row = $queue->fetch_by_path($relpath);
        return if $row->{status} && !$self->{force};

        $queue->bulk_insert({path => $relpath, status => 0});
      });
      $queue->finalize_bulk_insert;
    });
  }
  $pm->wait_all_children;

  my $count = db_r('Queue')->count_queued_items;
  $self->log(info => "queued $count dists");
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Queue

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 enqueue_cpan

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
