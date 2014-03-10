#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

WWW::CPANTS::Script::recalc_kwalitee->run_directly;

package WWW::CPANTS::Script::recalc_kwalitee;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::Process::Analysis;

sub _options {qw/trace profile/}

sub _run {
  my $self = shift;

  WWW::CPANTS::Process::Analysis->new(%$self)->recalc_kwalitee(@_);
}
