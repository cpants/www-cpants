package WWW::CPANTS::Util::Datetime;

use WWW::CPANTS;
use Exporter qw/import/;
use Time::Piece;
use Time::Seconds;

our @EXPORT = qw(
  strftime ymd ymdhms days_ago year datetime
);

sub strftime ($format, $epoch) {
  Time::Piece->new($epoch)->strftime($format);
}

sub ymdhms ($epoch) {
  Time::Piece->new($epoch)->strftime('%Y-%m-%d %H:%M:%S');
}

sub year ($epoch) {
  Time::Piece->new($epoch)->year;
}

sub ymd ($epoch) { Time::Piece->new($epoch)->ymd }

sub days_ago ($days) {
  Time::Piece->new - $days * ONE_DAY;
}

sub datetime ($epoch) {
  Time::Piece->new($epoch)->datetime.'Z';
}

1;
