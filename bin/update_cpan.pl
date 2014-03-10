#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

WWW::CPANTS::Script::update_cpan_info->run_directly;

package WWW::CPANTS::Script::update_cpan_info;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::Process::CPAN;

sub _options {qw/cpan=s/}

sub _run {
  my ($self, @args) = @_;

  WWW::CPANTS::Process::CPAN->new(%$self)->update;
}
