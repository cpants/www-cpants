#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";

WWW::CPANTS::Script::fix_extra_databases->run_directly;

package WWW::CPANTS::Script::fix_extra_databases;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::Process::Analysis;

sub _options {qw/trace profile/}

sub _run {
  my $self = shift;

  WWW::CPANTS::Process::Analysis->new(%$self)->fix_extra_databases(@_);
}
