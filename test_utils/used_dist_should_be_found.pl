#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

WWW::CPANTS::Script::used_dist_should_be_found->run_directly;

package WWW::CPANTS::Script::used_dist_should_be_found;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::DB::UsedModules;
use WorePAN;

sub _options {qw/cpan=s/}

sub _run {
  my ($self, @args) = @_;

  my $cpan = $self->{cpan} or die "requires cpan";
  my $worepan = WorePAN->new(root => $cpan);
  my %listed = map { $_->{module} => 1 } @{ $worepan->modules };

  my $db = WWW::CPANTS::DB::UsedModules->new;
  my $modules = $db->fetch_orphan_modules;
  my %seen;
  my %modules;
  for (@$modules) {
    next if $seen{$_}++;
    #print "$_\n" if $listed{$_};
    $modules{$_} = 1;
  }

  require IO::Zlib;
  my $index = $worepan->packages_details;
  my $fh = IO::Zlib->new($index->path, "rb") or die $!;

  %seen = ();
  my $done_preambles = 0;
  while(<$fh>) {
    chomp;
    if (/^\s*$/) {
      $done_preambles = 1;
      next;
    }
    next unless $done_preambles;

    /^(\S+)\s+\S+\s+(\S+)/ or next;
    if ($modules{$1}) {
      push @{ $seen{$2} ||= [] }, $1;
    }
  }
  for my $dist (sort keys %seen) {
    print "$dist\n";
    for my $module (@{$seen{$dist}}) {
      print "  $module\n";
    }
  }
}

