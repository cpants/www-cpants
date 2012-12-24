use strict;
use warnings;
use WWW::CPANTS::Test;

{
  package #
    WWW::CPANTS::Script::Test1;
  use base 'WWW::CPANTS::Script::Base';

  sub _run { WWW::CPANTS::Test::pass "Test1 runs" }

  package main;
  WWW::CPANTS::Script::Test1->run_directly;
}

{
  package #
    WWW::CPANTS::Script::Test2;
  use base 'WWW::CPANTS::Script::Base';

  sub _run {
    my $self = shift;
    WWW::CPANTS::Test::ok $self->{verbose};
  }

  package main;
  local @ARGV = qw/--verbose/;
  WWW::CPANTS::Script::Test2->run_directly;
}

{
  package #
    WWW::CPANTS::Script::Test3;
  use base 'WWW::CPANTS::Script::Base';

  sub _options { qw/my_option=s/ }

  sub _run {
    my $self = shift;
    WWW::CPANTS::Test::is $self->{my_option} => 'foo';
  }

  package main;
  local @ARGV = qw/--my_option foo/;
  WWW::CPANTS::Script::Test3->run_directly;
}

done_testing;
