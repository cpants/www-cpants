package WWW::CPANTS::Process::Analysis;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Analyze;
use WWW::CPANTS::Log;
use WWW::CPANTS::Parallel;
use Path::Extended;
use JSON::XS;
use Module::Find;

sub new {
  my ($class, %args) = @_;

  db('Analysis')->setup;

  bless \%args, $class;
}

sub process_queue {
  my ($self, %args) = @_;

  my $cpan = $args{cpan} || $self->{backpan} || $self->{cpan}
    or die "requires a CPAN mirror";
  my $dir = dir($cpan)->subdir('authors/id');
  die "$dir seems not a CPAN mirror" unless $dir->exists;

  my $timeout = $args{timeout} || $self->{timeout} || 600;
  my $limit   = $args{limit}   || $self->{limit} || 1000;
  my $capture = $args{capture} || 0;

  $timeout = 0 if $timeout < 0;

  my $pm = WWW::CPANTS::Parallel->new(
    max_workers => $args{workers} || $self->{workers},
  );

  my @extra_packages = $self->_load_extra_packages;

  my $checker = db_r('Queue');
  while(1) {
    last unless $checker->fetch_first_id;
    $pm->run(sub {
      my $queue       = db('Queue');
      my $analysis_db = db('Analysis');

      my @extra_databases = map { $_->new } @extra_packages;

      my $started = time;
      while (1) {
        last unless $limit-- > 0;
        last if $started - time > 600;
        my $id = $queue->mark;
        unless ($id) {
          last unless $queue->fetch_first_id;
          sleep 1;
          next;
        }
        my $path = $queue->fetch_path($id);
        if ($analysis_db->has_analyzed($path)) {
          next unless $args{force} || $self->{force};
        }
        $self->log(debug => "processing $path");
        my $start = time;
        my $analyze = WWW::CPANTS::Analyze->new(
          no_capture => !$capture,
          timeout => $timeout,
        );
        my $context = $analyze->analyze(
          dist => $dir->file($path)->path,
        );
        unless ($context) {
          $self->log(warn => "analysis aborted: $path");
          next;
        }
        next if $context->stash->{has_no_perl_stuff};

        my $analysis_id = $analysis_db->insert_or_update({
          path => $path,
          distv => $context->stash->{vname},
          author => $context->stash->{author},
          json => $context->dump_stash,
          duration => time - $start,
        });
        $context->stash->{id} = $analysis_id;

        $_->update($context->stash) for @extra_databases;

        $queue->mark_done($id);
      }
      $analysis_db->finalize_bulk_insert;

      $_->finalize for @extra_databases;
    });
  }
  $pm->wait_all_children;
}

sub _load_extra_packages {
  my ($self, @tables) = @_;

  my %map = map {$_ => 1} @tables;
  my @loaded;
  for my $package (findsubmod 'WWW::CPANTS::Process::Analysis') {
    my ($name) = $package =~ /::(\w+)$/;
    if (!%map or $map{$name}) {
      eval "require $package; 1" or do { warn $@; next };
      push @loaded, $package;
    }
  }
  @loaded;
}

sub fix_extra_databases {
  my $self = shift;

  my @databases = map { $_->new } $self->_load_extra_packages(@_);

  my $db = WWW::CPANTS::DB::Analysis->new;
  my $ct = 0;
  while(my $row = $db->iterate(qw/id json/)) {
    my $data = decode_json($row->{json});
    $data->{id} = $row->{id};
    $_->update($data) for @databases;
    $self->log(debug => "processed $ct") unless ++$ct % 1000;
  }
  $_->finalize for @databases;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Analysis

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 process_queue
=head2 fix_extra_databases

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
