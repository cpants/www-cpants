use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::AppRoot;

my $approot = WWW::CPANTS::AppRoot->approot;
ok $approot && $approot->exists, "approot exists";
ok $approot->file('Makefile.PL')->exists, "approot always has Makefile.PL";

{
  local $ENV{HARNESS_ACTIVE};
  my $root = WWW::CPANTS::AppRoot->root;
  is $root => $approot, "root is approot";
  ok $root->file('Makefile.PL')->exists, "root has Makefile.PL";
}

{
  my $root = WWW::CPANTS::AppRoot->root;
  isnt $root => $approot, "root is not approot";
  ok !$root->file('Makefile.PL')->exists, "root doesn't have Makefile.PL";
  note "root: " . $root->relative($approot);
}

ok appfile('Makefile.PL')->exists, "approot has Makefile.PL";
ok !file('Makefile.PL')->exists, "root doesn't have Makefile.PL";

done_testing;
