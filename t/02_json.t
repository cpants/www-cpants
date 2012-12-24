use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::JSON;

my $expected = {test => 1};

save_json('test', $expected);

my $got = slurp_json('test');

is_deeply $got => $expected, "got correct json";

save_json('test', undef); # to remove

ok !-f json_file('test'), "test file is gone";

done_testing;
