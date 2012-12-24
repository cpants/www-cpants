use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB::Base;

my $db = WWW::CPANTS::DB::Base->new;

ok $db, "created an object";
is $db->table => 'base', "correct table";
is $db->dbname => 'base.db', "correct dbname";
is $db->dbfile->basename => 'base.db', "correct dbfile";

$db->setup;
{
  my $row = $db->fetch("select * from sqlite_master where name=?", "base");
  is $row->{name} => "base", "got correct table definition";
}

{ # bulk insert
  $db->bulk_insert({id => $_, text => "text$_"}) for 1..1000;
  $db->finalize_bulk_insert;
  my $row = $db->fetch("select * from base where id = ?", 100);
  is $row->{text} => "text100", "got a correct row";
  my $ct = $db->fetch_1("select count(*) from base");
  is $ct => 1000, "num of rows";
}

{ # redo bulk insert
  $db->bulk_insert({id => $_, text => "text$_"}) for 1001..2000;
  $db->finalize_bulk_insert;
  my $row = $db->fetch("select * from base where id = ?", 100);
  is $row->{text} => "text100", "got a correct row";
  my $ct = $db->fetch_1("select count(*) from base");
  is $ct => 2000, "num of rows";
}

{ # iterate
  my $ct = 0;
  while(my $row = $db->iterate) {
    $ct++ if $row && ref $row eq ref {} && $row->{id};
  }
  is $ct => 2000, "num of rows";
}

{ # iterate
  my $ct = 0;
  while(my $id = $db->iterate('id')) {
    $ct++ if $id && !ref $id;
  }
  is $ct => 2000, "num of rows";
}

{ # iterate
  my $ct = 0;
  while(my $row = $db->iterate(qw/id text/)) {
    $ct++ if $row && ref $row eq ref {} && $row->{id} && $row->{text};
  }
  is $ct => 2000, "num of rows";
}

done_testing;
