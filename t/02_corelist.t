use strict;
use warnings;
use Test::More;
use WWW::CPANTS::CoreList;

my $perl_version = WWW::CPANTS::CoreList::perl_version();
ok $perl_version =~ /^5\.(\d+)/, "perl_version: $perl_version";

ok is_core('ExtUtils::MakeMaker'), "EUMM should always be in the core";

$perl_version = WWW::CPANTS::CoreList::perl_version('5.008');
ok $perl_version =~ /^5\.008/, "perl_version: $perl_version";

ok is_core('ExtUtils::MakeMaker'), "EUMM should always be in the core";
ok is_core('Encode'), "Encode should be in the core of 5.008";
$perl_version = WWW::CPANTS::CoreList::perl_version('5.000');
ok $perl_version =~ /^5\.000/, "perl_version: $perl_version";

ok is_core('ExtUtils::MakeMaker'), "EUMM should always be in the core";
ok !is_core('Encode'), "Encode should not be in the core of 5.000";

done_testing;
