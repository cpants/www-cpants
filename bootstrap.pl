#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";

WWW::CPANTS::Script::bootstrap->run_directly;

package WWW::CPANTS::Script::bootstrap;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::Process::Bootstrap;

sub _options {qw/force|f/}

sub _run {
  my $self = shift;

  WWW::CPANTS::Process::Bootstrap->new(%$self)->update(@_);
}
