use Mojo::Base -strict, -signatures;
use Test::More;
use Test::Perl::Critic;

all_critic_ok(qw/author bin lib t xt/, glob "*.psgi");
