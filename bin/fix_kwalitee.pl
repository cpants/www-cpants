#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

WWW::CPANTS::Script::fix_kwalitee->run_directly;

package WWW::CPANTS::Script::fix_kwalitee;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::Process::Kwalitee;

sub _options {qw/profile trace workers=s/}

sub _run {
  my $self = shift;

  WWW::CPANTS::Process::Kwalitee->new(%$self)->update(@_);
}
