#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";

WWW::CPANTS::Script::update_uploads->run_directly;

package WWW::CPANTS::Script::update_uploads;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::Process::Uploads;

sub _options {qw/cpan=s backpan=s workers=s/}

sub _run {
  my ($self, @args) = @_;

  WWW::CPANTS::Process::Uploads->new(%$self)->update;
}
