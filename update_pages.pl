#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";

WWW::CPANTS::Script::update_pages->run_directly;

package WWW::CPANTS::Script::update_pages;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::Pages;

sub _run {
  my ($self, @target) = @_;

  WWW::CPANTS::Pages->update(@target);
}
