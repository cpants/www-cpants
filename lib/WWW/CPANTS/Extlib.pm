package WWW::CPANTS::Extlib;

use strict;
use warnings;
use WWW::CPANTS::AppRoot;
use lib glob appdir("extlib/*/lib")->path;

1;
