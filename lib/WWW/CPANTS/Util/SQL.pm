package WWW::CPANTS::Util::SQL;

use WWW::CPANTS;
use Exporter qw/import/;
use DBI qw/:sql_types/;

our @EXPORT = (
    @{ $DBI::EXPORT_TAGS{sql_types} },
);

1;
