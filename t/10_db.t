use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;

WWW::CPANTS::DB::load_all();

my @databases = WWW::CPANTS::DB::loaded();

ok @databases, "loaded ".(scalar @databases)." databases";

for my $name (@databases) {
  db($name)->setup;
}

eval { db('NotExists') };
ok $@, "dies if a database name is wrong";

my $db = db('Kwalitee', profile => 1);
ok $db->{profile}, "option is passed";

unlink $db->dbfile;
ok !$db->dbfile->exists, "dbfile does not exist";
eval { db_r('Kwalitee') };
ok $@, "dies if a readonly database does not exist";
ok !$db->dbfile->exists, "readonly does not create a database";

done_testing;
