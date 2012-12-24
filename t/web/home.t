use strict;
use warnings;
use WWW::CPANTS::AppRoot;
use WWW::CPANTS::Test;
use WWW::CPANTS::Page::Home;
use Test::Mojo;

my $psgi = appfile("cpants.psgi");
do $psgi;

WWW::CPANTS::Page::Home->create_data;

my $t = Test::Mojo->new;
$t->get_ok('/')->status_is(200);

done_testing;
