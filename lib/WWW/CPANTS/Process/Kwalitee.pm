package WWW::CPANTS::Process::Kwalitee;

use strict;
use warnings;
use WWW::CPANTS::DB::Kwalitee;
use WWW::CPANTS::DB::Authors;
use WWW::CPANTS::DB::DistAuthors;
use WWW::CPANTS::DB::DistModules;
use WWW::CPANTS::DB::PrereqModules;
use WWW::CPANTS::DB::UsedModules;
use WWW::CPANTS::DB::Errors;
use WWW::CPANTS::DB::Uploads;
use WWW::CPANTS::Log;
use WWW::CPANTS::Kwalitee;

sub new {
  my ($class, %args) = @_;

  WWW::CPANTS::DB::Kwalitee->new->setup;
  WWW::CPANTS::DB::Authors->new->setup;
  WWW::CPANTS::DB::DistAuthors->new->setup;
  WWW::CPANTS::DB::DistModules->new->setup;
  WWW::CPANTS::DB::PrereqModules->new->setup;
  WWW::CPANTS::DB::UsedModules->new->setup;
  WWW::CPANTS::DB::Errors->new->setup;
  WWW::CPANTS::DB::Uploads->new->setup;

  require Module::CoreList;
  $args{is_core} = $Module::CoreList::version{$^V->numify};

  bless \%args, $class;
}

sub update_all {
  my $self = shift;

  $self->update_prereq_dist;
  $self->update_used_module_dist;
  $self->update_is_prereq;
  $self->update_prereq_matches_use;
  $self->update_is_cpan;
  $self->update_is_latest;
  $self->update_kwalitee;
  $self->update_authors_stat;
}

sub update_prereq_dist {
  my $self = shift;

  $self->log(debug => "updating prereq dist");

  my $prereq_db = WWW::CPANTS::DB::PrereqModules->new;
  my $dist_modules_db = WWW::CPANTS::DB::DistModules->new;

  my $ct = 0;
  my $prereqs = $prereq_db->fetch_all_prereqs;
  for my $prereq (@$prereqs) {

    # TODO: also check prereq_version when ready
    if (
      $prereq eq 'perl'
      or exists $self->{is_core}{$prereq}
    ) {
      $prereq_db->update_prereq_dist($prereq, 'perl');
    }
    else {
      my $dists = $dist_modules_db->dists_by_modules($prereq);
      if (@$dists) {
        if (@$dists > 1) {
          $self->log(warn => "$prereq is listed in more than one dists (@$dists)");
        }
        $prereq_db->update_prereq_dist($prereq, $dists->[0]);
      }
      else {
        $self->log(debug => "no dists has $prereq");
        $prereq_db->update_prereq_dist($prereq, '');
      }
    }
    $self->log(debug => "updated $ct prereq dists") unless ++$ct % 1000;
  }
}

sub update_used_module_dist {
  my $self = shift;

  $self->log(debug => "updating used module dist");

  my $used_db = WWW::CPANTS::DB::UsedModules->new;
  my $dist_modules_db = WWW::CPANTS::DB::DistModules->new;

  my $ct = 0;
  my $modules = $used_db->fetch_all_used_modules;
  for my $module (@$modules) {
    if (
      $module eq 'perl'
      or exists $self->{is_core}{$module}
    ) {
      $used_db->update_used_module_dist($module, 'perl');
    }
    else {
      my $dists = $dist_modules_db->dists_by_modules($module);
      if (@$dists) {
        if (@$dists > 1) {
          $self->log(warn => "$module is listed in more than one dists (@$dists)");
        }
        $used_db->update_used_module_dist($module, $dists->[0]);
      }
      else {
        $self->log(debug => "no dists has $module");
        $used_db->update_used_module_dist($module, '');
      }
    }
    $self->log(debug => "updated $ct used module dists") unless ++$ct % 1000;
  }
}

sub update_is_prereq {
  my $self = shift;

  $self->log(debug => "updating is_prereq");

  my $prereq_db = WWW::CPANTS::DB::PrereqModules->new;
  my $kwalitee_db = WWW::CPANTS::DB::Kwalitee->new;
  my $dist_authors_db = WWW::CPANTS::DB::DistAuthors->new;

  my $dists = $prereq_db->fetchall_prereq_dists;
  my @required_by_others;
  my $ct = 0;
  for my $dist (@$dists) {
    next unless $dist;
    my $authors = $dist_authors_db->fetch_authors($dist);
    $kwalitee_db->update_is_prereq($dist, $authors);
    # $self->log(debug => "updated dists that require $dist");
    $self->log(debug => "updated $ct is_prereq") unless ++$ct % 1000;
  }
}

sub update_prereq_matches_use {
  my $self = shift;

  $self->log(debug => "updating prereq_matches_use");

  my $prereq_db = WWW::CPANTS::DB::PrereqModules->new;
  my $used_db = WWW::CPANTS::DB::UsedModules->new;
  my $kwalitee_db = WWW::CPANTS::DB::Kwalitee->new;
  my $errors_db = WWW::CPANTS::DB::Errors->new;

  my $ct = 0;
  while(my $row = $kwalitee_db->fetchrow) {
    my $used = $used_db->fetch_used_modules_of($row->{distv});
    my @not_core = grep { $_->{module_dist} && $_->{module_dist} ne 'perl' && !exists $self->{is_core}{$_->{module}} } @$used;

    my %should_be_prereq = map { $_->{module_dist} => 1 } grep { $_->{in_code} } @not_core;
    my %should_be_build_prereq = map { $_->{module_dist} => 1 } grep { $_->{in_tests} } @not_core;

    my $prereqs = $prereq_db->fetch_prereqs_of($row->{distv});
    for my $prereq (@$prereqs) {
      delete $should_be_prereq{$prereq->{prereq_dist}} if $prereq->{type} == 1;
      delete $should_be_build_prereq{$prereq->{prereq_dist}};
    }

    my @missing_prereq = sort keys %should_be_prereq;
    my @missing_build_prereq = sort keys %should_be_build_prereq;
    $kwalitee_db->update_prereq_matches_use(
      $row->{distv},
      @missing_prereq ? 0 : 1,
      @missing_build_prereq ? 0 : 1,
    );

    $errors_db->bulk_insert({
      distv => $row->{distv},
      name => 'missing_prereq',
      error => \@missing_prereq,
    }) if @missing_prereq;

    $errors_db->bulk_insert({
      distv => $row->{distv},
      name => 'missing_build_prereq',
      error => \@missing_build_prereq,
    }) if @missing_build_prereq;

    $self->log(debug => "updated $ct prereq_matches") unless ++$ct % 1000;
  }
  $errors_db->finalize_bulk_insert;
}

sub update_is_cpan {
  my $self = shift;

  $self->log(debug => "updating is_cpan");

  my $uploads_db = WWW::CPANTS::DB::Uploads->new;
  my $kwalitee_db = WWW::CPANTS::DB::Kwalitee->new;

  $kwalitee_db->mark_current_cpan;

  my $ct = 0;
  my $cpan_dists = $uploads_db->cpan_dists;
  while(my @dists = splice @$cpan_dists, 0, 100) {
    $kwalitee_db->mark_cpan(\@dists);
    $ct += 100;
    $self->log(debug => "updated $ct is_cpan") unless $ct % 1000;
  }
  $kwalitee_db->unmark_previous_cpan;
}

sub update_is_latest {
  my $self = shift;

  $self->log(debug => "updating is_latest");

  my $uploads_db = WWW::CPANTS::DB::Uploads->new;
  my $kwalitee_db = WWW::CPANTS::DB::Kwalitee->new;

  $kwalitee_db->mark_current_latest;

  my $ct = 0;
  my $latest_dists = $uploads_db->latest_dists;
  while(my @dists = splice @$latest_dists, 0, 100) {
    $kwalitee_db->mark_latest(\@dists);
    $ct += 100;
    $self->log(debug => "updated $ct is_latest") unless $ct % 1000;
  }
  $kwalitee_db->unmark_previous_latest;
}

sub update_kwalitee {
  my $self = shift;

  $self->log(debug => "updating kwalitee scores");

  my $kwalitee_db = WWW::CPANTS::DB::Kwalitee->new;
  my @metrics = kwalitee_metrics();
  if (!@metrics) {
    save_metrics();
    @metrics = kwalitee_metrics();
  }

  my $num_of_core_indicators = 0;
  my (@core, @extra);
  for (kwalitee_metrics()) {
    if ($_->{is_experimental}) {
      next;
    }
    elsif ($_->{is_extra}) {
      push @extra, $_->{name};
    }
    else {
      push @core, $_->{name};
      $num_of_core_indicators++;
    }
  }

  my $ct = 0;
  while(my $row = $kwalitee_db->fetchrow) {
    my $core  = 0;
    my $extra = 0;
    for (@core) {
      $core++ if $row->{$_};
    }
    for (@extra) {
      $extra++ if $row->{$_};
    }
    $extra += $core;

    $row->{kwalitee}      = 100 * $extra / $num_of_core_indicators;
    $row->{core_kwalitee} = 100 * $core / $num_of_core_indicators;
    $kwalitee_db->update_final_kwalitee($row);
    $self->log(debug => "updated $ct kwalitee") unless ++$ct % 1000;
  }
}

sub update_authors_stat {
  my $self = shift;

  $self->log(debug => "updating authors stat");

  my $kwalitee_db = WWW::CPANTS::DB::Kwalitee->new;
  my $authors_db = WWW::CPANTS::DB::Authors->new;

  my $ct = 0;
  my $stats = $kwalitee_db->fetch_authors_stats;
  $authors_db->update_authors_stats($stats);
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Kwalitee

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
