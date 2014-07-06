package WWW::CPANTS::Process::Kwalitee::PrereqMatchesUse;

use strict;
use warnings;
use WWW::CPANTS::Log;
use WWW::CPANTS::DB;
use WWW::CPANTS::Util::CoreList;
use WWW::CPANTS::Util::Parallel;

sub new {
  my ($class, %args) = @_;
  bless \%args, $class;
}

sub update {
  my $self = shift;

  $self->log(debug => "updating prereq_matches_use");

  my $kwalitee_db = db('Kwalitee');
  my $errors_db = db('Errors');

  my $rows = $kwalitee_db->fetch_all_prereq_matches_use;
  $self->log(debug => 'Processing '.(scalar @$rows).' dists');

  my $pm = WWW::CPANTS::Util::Parallel->new(
    max_workers => $self->{workers},
  );

  $errors_db->mark(qw/missing_prereqs missing_build_prereqs/);

  my $ct = 0;
  while (my @r = splice @$rows, 0, 10000) {
    $ct += @r;
    $self->log(debug => "processing $ct dists");
    $pm->run(sub {
      $self->_update(\@r);
    });
  }
  $pm->wait_all_children;

  $kwalitee_db->update_dynamic_prereq_matches_use;

  $errors_db->unmark(qw/missing_prereqs missing_build_prereqs/);
}

sub _update {
  my ($self, $rows) = @_;

  my $kwalitee_db = db('Kwalitee');
  my $errors_db = db('Errors');
  my $prereq_db = db_r('PrereqModules');
  my $used_db = db_r('UsedModules');

  for my $row (@$rows) {
    my $analysis_id = $row->{analysis_id};
    my $distv = $row->{distv};
    my $used = $used_db->fetch_used_modules_of($distv);
    my @not_core = grep { $_->{module_dist} && $_->{module_dist} ne 'perl' && !is_core($_->{module}) } @$used;

    my %should_be_prereq = map { $_->{module_dist} => 1 } grep { $_->{used_in_code} or $_->{required_in_code} } @not_core;
    my %should_be_build_prereq = map { $_->{module_dist} => 1 } grep { $_->{used_in_tests} or $_->{required_in_tests} } @not_core;

    my $prereqs = $prereq_db->fetch_prereqs_of($distv);
    for my $prereq (@$prereqs) {
      next unless $prereq->{prereq_dist};
      delete $should_be_prereq{$prereq->{prereq_dist}} if $prereq->{type} == 1 or $prereq->{type} == 3;
      delete $should_be_build_prereq{$prereq->{prereq_dist}};
    }

    my $missing_prereqs = join ',', sort keys %should_be_prereq;
    my $missing_build_prereqs = join ',', sort keys %should_be_build_prereq;
    my $prereq_matches_use = $missing_prereqs ? 0 : 1;
    my $build_prereq_matches_use = $missing_build_prereqs ? 0 : 1;

    if (
      $prereq_matches_use ne ($row->{prereq_matches_use} || '') or
      $build_prereq_matches_use ne ($row->{build_prereq_matches_use} || '')
    ) {
      $kwalitee_db->update_prereq_matches_use(
        $distv,
        $prereq_matches_use,
        $build_prereq_matches_use,
      );
    }

    $errors_db->bulk_insert({
      analysis_id => $analysis_id,
      distv => $distv,
      category => 'missing_prereqs',
      error => $missing_prereqs,
    }) if $missing_prereqs;

    $errors_db->bulk_insert({
      analysis_id => $analysis_id,
      distv => $distv,
      category => 'missing_build_prereqs',
      error => $missing_build_prereqs,
    }) if $missing_build_prereqs;
  }
  $errors_db->finalize_bulk_insert;
  $kwalitee_db->finalize_update_prereq_matches_use;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Kwalitee::PrereqMatchesUse

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 update

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
