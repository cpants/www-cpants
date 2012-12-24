use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Utils;

like date()     => qr{^20[0-9]{2}\-[01][0-9]\-[0-3][0-9]$}, "date";
like datetime() => qr{^20[0-9]{2}\-[01][0-9]\-[0-3][0-9] [0-5][0-9]:[0-5][0-9]:[0-5][0-9]$}, "datetime";
is decimal(5.004) => "5.00", "decimal";
is decimal(5.005) => "5.01", "decimal";
is percent(50) => "50.00", "percent";
is percent(50, 100) => "50.00", "percent";
is kb(1530) => "1.53 KB", "1.53 kb";
is kb(2780000) => "2.78 MB", "2.78 mb";
is kb(100) => "100 bytes", "100 bytes";

done_testing;
