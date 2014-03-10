#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

WWW::CPANTS::Script::minifier->run_directly;

package WWW::CPANTS::Script::minifier;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::Process::Minify;
use WWW::CPANTS::Process::GzipStaticFiles;

sub _run {
  my $self = shift;
  WWW::CPANTS::Process::Minify->new(%$self)->minify;
  WWW::CPANTS::Process::GzipStaticFiles->new(%$self)->compress;
}
