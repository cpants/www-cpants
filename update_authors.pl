#!/usr/bin/env perl
use strict;
use warnings;
use lib "lib";

WWW::CPANTS::Script::update_authors->run_directly;

package WWW::CPANTS::Script::update_authors;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::Process::Authors;

sub _options {qw/cpan=s/}

sub _run {
  my ($self, @args) = @_;

  WWW::CPANTS::Process::Authors->new->update_authors(%$self);
}
