use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;
use WWW::CPANTS::Process::Queue;
use WWW::CPANTS::Process::Analysis;

my @should_be_ignored = (
  # no .pm nor .PL
  'H/HM/HMBRAND/cshmen-3.50_01.tgz',
);

my @shouldnt_be_ignored = (
  # no .pm, only .PL
  'M/ML/MLEHMANN/common-sense-3.6.tar.gz',
);

my @paths = (@should_be_ignored, @shouldnt_be_ignored);

my $mirror = setup_mirror(@paths);
my $cpan = $mirror->root;

WWW::CPANTS::Process::Queue->new->enqueue_cpan(cpan => $cpan);
WWW::CPANTS::Process::Analysis->new->process_queue(cpan => $cpan);

my $queued = db_r('Queue')->fetch_1('select count(*) from queue');
my $analyzed = db_r('Analysis')->fetch_1('select count(*) from analysis');

is $queued => @paths, "queued distributions with no .pm or .PL";
is $analyzed => @shouldnt_be_ignored, "ignored distributions with no .pm or .PL";

done_testing;
