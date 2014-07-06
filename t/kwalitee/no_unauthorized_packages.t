use strict;
use warnings;
use WWW::CPANTS::AppRoot;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;
use WWW::CPANTS::Process::Queue;
use WWW::CPANTS::Process::Permissions;
use WWW::CPANTS::Process::Analysis;
use WWW::CPANTS::Process::Kwalitee;
use CPAN::DistnameInfo;

my @tests = (
  ['ISHIGAKI/Path-Extended-0.19.tar.gz', 1],
  ['TOKUHIROM/URI-Builder-0.01.tar.gz', 0],
);

my $mirror = setup_mirror(map {$_->[0]} @tests);
my $root = $mirror->root->path;

my $local_mirror = appdir('tmp/test_mirror');
my $local_perms = $local_mirror->file('modules/06perms.txt');
if ($local_perms->exists) {
  $local_perms->copy_to($mirror->root->subdir('modules')->mkdir);
}

note "updating permissions database";
WWW::CPANTS::Process::Permissions->new->update(
  cpan => $root,
);

my $perms = $mirror->root->file('modules/06perms.txt');
if (!$local_perms->exists and $perms->exists) {
  $perms->copy_to($local_mirror->subdir('modules'));
}

note "enqueue";
WWW::CPANTS::Process::Queue->new->enqueue_cpan(cpan => $root);

note "analyze";
WWW::CPANTS::Process::Analysis->new->process_queue(cpan => $root);

note "updating kwalitee databases";
WWW::CPANTS::Process::Kwalitee->new->update(qw/
  Permissions
/);

for my $test (@tests) {
  my $distv = CPAN::DistnameInfo->new($test->[0])->distvname;
  my $row = db('Kwalitee')->fetch_distv($distv);
  my $result = $row->{no_unauthorized_packages};
  is $result => $test->[1], $test->[0] . " no_unauthorized_packages: $result";

  note explain db('Errors')->fetch_distv_errors($distv);
}

done_testing;
