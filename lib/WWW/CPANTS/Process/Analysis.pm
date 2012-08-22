package WWW::CPANTS::Process::Analysis;

use strict;
use warnings;
use WWW::CPANTS::DB::Queue;
use WWW::CPANTS::DB::Analysis;
use WWW::CPANTS::DB::DistAuthors;
use WWW::CPANTS::DB::DistModules;
use WWW::CPANTS::DB::PrereqModules;
use WWW::CPANTS::DB::UsedModules;
use WWW::CPANTS::DB::Kwalitee;
use WWW::CPANTS::DB::Errors;
use WWW::CPANTS::Analyze;
use WWW::CPANTS::Log;
use WWW::CPANTS::ForkManager;
use Scope::OnExit;
use Path::Extended;
use JSON::XS;

sub new {
  my ($class, %args) = @_;

  WWW::CPANTS::DB::Queue->new->setup;
  WWW::CPANTS::DB::Analysis->new->setup;
  WWW::CPANTS::DB::DistAuthors->new->setup;
  WWW::CPANTS::DB::DistModules->new->setup;
  WWW::CPANTS::DB::PrereqModules->new->setup;
  WWW::CPANTS::DB::UsedModules->new->setup;
  WWW::CPANTS::DB::Kwalitee->new->setup;
  WWW::CPANTS::DB::Errors->new->setup;

  bless \%args, $class;
}

sub process_queue {
  my ($self, %args) = @_;

  my $cpan = $args{cpan} || $self->{cpan} or die "requires a CPAN mirror";
  my $dir = dir($cpan)->subdir('authors/id');
  die "$dir seems not a CPAN mirror" unless $dir->exists;

  my $timeout = $args{timeout} || $self->{timeout} || 600;
  my $limit   = $args{limit}   || $self->{limit} || 1000;
  my $capture = $args{capture} || 0;

  $timeout = 0 if $timeout < 0;

  my $pm;
  if (my $workers = $args{workers} || $self->{workers}) {
    $pm = WWW::CPANTS::ForkManager->new(
       max_workers => $workers,
       on_child_reap => sub {
         my ($pid, $exit, $id) = @_;
         print "finished (pid: $pid, exit: $exit)\n";
       },
    );
  }

  my $checker = WWW::CPANTS::DB::Queue->new;
  while(1) {
    last unless $checker->get_first_id;
    $pm and $pm->start and do { sleep 1; next };

    on_scope_exit { $pm and $pm->finish(0) };

    my $queue       = WWW::CPANTS::DB::Queue->new;
    my $analysis_db = WWW::CPANTS::DB::Analysis->new;

    my %db = (
      dist_authors   => WWW::CPANTS::DB::DistAuthors->new,
      dist_modules   => WWW::CPANTS::DB::DistModules->new,
      prereq_modules => WWW::CPANTS::DB::PrereqModules->new,
      used_modules   => WWW::CPANTS::DB::UsedModules->new,
      kwalitee       => WWW::CPANTS::DB::Kwalitee->new,
      errors         => WWW::CPANTS::DB::Errors->new,
    );

    while (1) {
      last unless $limit--;
      my $id = $queue->mark or last;
      my $path = $queue->get_path($id);
      if ($analysis_db->has_analyzed($path)) {
        next unless $args{force} || $self->{force};
      }
      $self->log(debug => "[$$] processing $path");
      my $start = time;
      my $analyze = WWW::CPANTS::Analyze->new(
        no_capture => !$capture,
        timeout => $timeout,
      );
      my $context = $analyze->analyze(
        dist => $dir->file($path)->path,
      );
      unless ($context) {
        $self->log(warn => "[$$] analysis aborted: $path");
        next;
      }
      my $analysis_id = $analysis_db->insert_or_update({
        path => $path,
        distv => $context->stash->{vname},
        author => $context->stash->{author},
        json => $context->dump_stash,
        duration => time - $start,
      });
      $context->stash->{id} = $analysis_id;

      $self->store_data(\%db, $context->stash);

      $queue->mark_done($id);
    }

    $_->finalize_bulk_insert for values %db;
  }
  $pm and $pm->wait_all_children;
}

# store small parts of the stash into other databases so that
# we can avoid locking issues on a huge SQLite database
# and can also avoid glitches from Module::CPANTS::Kwalitee's
# incompatible changes. 
# these databases are also supposed to be used standalone,
# so don't normalize too much to avoid too much joining.
# as of this writing, copied parts are not removed from the
# stash.

sub store_data {
  my ($self, $db, $data) = @_;

  $self->store_dist_authors($db->{dist_authors}, $data);
  $self->store_dist_modules($db->{dist_modules}, $data);
  $self->store_prereq_modules($db->{prereq_modules}, $data);
  $self->store_used_modules($db->{used_modules}, $data);
  $self->store_kwalitee($db->{kwalitee}, $data);
  $self->store_errors($db->{errors}, $data);
}

sub store_dist_authors {
  my ($self, $db, $data) = @_;

  $db->bulk_insert({
    dist   => $data->{dist},
    author => $data->{author},
  });
}

sub store_dist_modules {
  my ($self, $db, $data) = @_;

  for my $module (@{ $data->{modules} || []}) {
    $db->bulk_insert({
      dist     => $data->{dist},
      distv    => $data->{vname},
      module   => $module->{module},
      released => $data->{released_epoch},

      # TODO: get something from CPAN::ParseDistribution
      # to improve $data->{versions}{$module->file}
      version  => 0,
    });
  }
}

sub store_prereq_modules {
  my ($self, $db, $data) = @_;

  for my $prereq (@{ $data->{prereq} || []}) {
    $db->bulk_insert({
      distv  => $data->{vname},
      prereq => $prereq->{requires},
      prereq_version => $prereq->{version},
      type => (
        $prereq->{is_prereq} ? 1 :
        $prereq->{is_build_prereq} ? 2 :
        1  # optional (recommendations)
      ),
    });
  }
}

sub store_used_modules {
  my ($self, $db, $data) = @_;

  my $uses = $data->{uses} || {};
  for my $key (keys %$uses) {
    next if !$key; # ignore evaled stuff
    next if $key =~ /^v?5/; # ignore perl
    $db->bulk_insert({
      distv    => $data->{vname},
      module   => $key,
      in_code  => $uses->{$key}{in_code} || 0,
      in_tests => $uses->{$key}{in_tests} || 0,
    });
  }
}

sub store_kwalitee {
  my ($self, $db, $data) = @_;

  my $kwalitee = $data->{kwalitee};
  $db->bulk_insert({
    analysis_id => $data->{id},
    dist => $data->{dist},
    distv => $data->{vname},
    author => $data->{author},
    released => $data->{released_epoch},
    %$kwalitee,
  });
}

sub store_errors {
  my ($self, $db, $data) = @_;

  my $errors = $data->{error} || {};
  $db->bulk_insert({
    distv => $data->{vname},
    name => $_,
    error => ref $errors->{$_} ? encode_json($errors->{$_}) : $errors->{$_},
  }) for keys %$errors;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Kwalitee

=head1 SYNOPSIS

=hzzead1 DESCRIPTION

=head1 METHODS

=head2 new

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
