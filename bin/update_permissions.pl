#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

WWW::CPANTS::Script::update_permissions->run_directly;

package WWW::CPANTS::Script::update_permissions;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::Process::Permissions;

sub _options {qw/cpan=s/}

sub _run {
  my ($self, @args) = @_;

  WWW::CPANTS::Process::Permissions->new(%$self)->update;
}
